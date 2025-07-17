package com.vpbankhackathon.transaction_monitoring.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vpbankhackathon.transaction_monitoring.models.dtos.AlertEvent;
import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionInfo;
import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionListResponse;
import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionMonitoringRequest;
import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionMonitoringResponse;
import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionMonitoringResult;
import com.vpbankhackathon.transaction_monitoring.models.entities.Transaction;
import com.vpbankhackathon.transaction_monitoring.models.entities.TransactionEntity;
import com.vpbankhackathon.transaction_monitoring.pubsub.producers.AlertCaseRequestProducer;
import com.vpbankhackathon.transaction_monitoring.pubsub.producers.RequestAckProducer;
import com.vpbankhackathon.transaction_monitoring.pubsub.producers.TransactionMonitoringResultProducer;
import com.vpbankhackathon.transaction_monitoring.repository.jpa.TransactionJpaRepository;
import com.vpbankhackathon.transaction_monitoring.repository.neo4j.TransactionRepository;

@Service
public class TransactionMonitoringService {

    @Autowired
    private TransactionJpaRepository transactionJpaRepository;

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private TransactionMonitoringResultProducer transactionMonitoringResultProducer;

    @Autowired
    private RequestAckProducer requestAckProducer;

    @Autowired
    private AlertCaseRequestProducer alertCaseProducer;

    private static final long LARGE_TRANSACTION_THRESHOLD = 5000L;
    private static final int SMURFING_COUNT_THRESHOLD = 3;
    private static final List<String> HIGH_RISK_COUNTRIES = Arrays.asList("Iran", "North Korea", "Syria");

    @Transactional
    public TransactionMonitoringResponse monitorTransaction(Long id, TransactionMonitoringRequest request) {
        TransactionMonitoringResponse response = new TransactionMonitoringResponse();
        response.setTransactionId(id);

        // Kiểm tra PostgreSQL
        TransactionEntity transaction = transactionJpaRepository.findById(id).orElse(null);
        if (transaction == null) {
            response.setStatus("FAIL");
            response.setReason("Transaction not found");
            return response;
        }

        // Smurfing Detection
        LocalDateTime endTime = LocalDateTime.now();
        LocalDateTime startTime = endTime.minusDays(7);
        List<TransactionEntity> smurfingTransactions = transactionJpaRepository.findTransactionsBetweenAccounts(
                transaction.getFromAccount(),
                transaction.getToAccount(),
                startTime,
                endTime
        );
        long smallTransactionCount = smurfingTransactions.stream()
                .filter(t -> t.getTransactionAmount() < 1000L)
                .count();
        if (smallTransactionCount > SMURFING_COUNT_THRESHOLD) {
            transaction.setIsSuspiciousTransaction(true);
            transactionJpaRepository.save(transaction);
            response.setStatus("FAIL");
            response.setReason("Potential smurfing detected: " + smallTransactionCount + " small transactions in 7 days");
            return response;
        }

        // Large Transaction Detection
        if (transaction.getTransactionAmount() > LARGE_TRANSACTION_THRESHOLD) {
            transaction.setIsSuspiciousTransaction(true);
            transactionJpaRepository.save(transaction);
            response.setStatus("FAIL");
            response.setReason("Large transaction detected: Amount = " + transaction.getTransactionAmount());
            return response;
        }

        // High-Risk Jurisdiction Detection
        if (HIGH_RISK_COUNTRIES.contains(transaction.getCountry())) {
            transaction.setIsSuspiciousTransaction(true);
            transactionJpaRepository.save(transaction);
            response.setStatus("FAIL");
            response.setReason("Transaction involves high-risk country: " + transaction.getCountry());
            return response;
        }

        // Circular Transaction Detection (Neo4j)
        try {
            List<Transaction> circularTransactions = transactionRepository.findCircularTransactions();
            boolean isCircular = circularTransactions.stream()
                    .anyMatch(t -> t.getId().equals(id));
            if (isCircular) {
                transaction.setIsSuspiciousTransaction(true);
                transactionJpaRepository.save(transaction);
                response.setStatus("FAIL");
                response.setReason("Circular transaction detected");
                return response;
            }
        } catch (Exception e) {
            System.err.println("Error checking circular transactions: " + e.getMessage());
        }

        response.setStatus("PASS");
        response.setReason("No issues found");
        return response;
    }

    @Transactional
    public void processTransactionEvent(TransactionMonitoringRequest event) {
        // Save to PostgreSQL
        TransactionEntity entity = new TransactionEntity();
        entity.setId(event.getTransactionId());
        entity.setTransactionAmount(event.getAmount());
        entity.setDate(event.getDate());
        entity.setFromAccount(event.getSourceAccountNumber());
        entity.setToAccount(event.getDestinationAccountNumber());
        entity.setCountry(event.getCountry());
        entity.setIsSuspiciousTransaction(false);
        entity.setIsConfirmedMoneyLaundering(false);
        transactionJpaRepository.save(entity);

        // Save to Neo4j
        transactionRepository.saveTransactionWithRelationships(
                event.getTransactionId(),
                event.getAmount(),
                event.getDate().atOffset(java.time.ZoneOffset.UTC),
                event.getCountry(),
                event.getSourceAccountNumber(),
                event.getDestinationAccountNumber(),
                false,
                false
        );

        // Monitor the transaction
        TransactionMonitoringResponse response = monitorTransaction(
                event.getTransactionId(),
                new TransactionMonitoringRequest()
        );

        if ("FAIL".equals(response.getStatus())) {
            // Update Neo4j with isSuspiciousTransaction
            transactionRepository.saveTransactionWithRelationships(
                    event.getTransactionId(),
                    event.getAmount(),
                    event.getDate().atOffset(java.time.ZoneOffset.UTC),
                    event.getCountry(),
                    event.getSourceAccountNumber(),
                    event.getDestinationAccountNumber(),
                    true,
                    false
            );

            // Send alert to alertcasemanagement
            AlertEvent alertEvent = new AlertEvent();
            alertEvent.setTransactionId(event.getTransactionId());
            alertEvent.setCustomerId(event.getCustomerId());
            alertEvent.setAmount(event.getAmount());
            alertEvent.setDate(event.getDate());
            alertEvent.setCountry(event.getCountry());
            alertEvent.setSourceAccountNumber(event.getSourceAccountNumber());
            alertEvent.setDestinationAccountNumber(event.getDestinationAccountNumber());
            alertEvent.setStatus("SUSPENDED");
            alertEvent.setReason(response.getReason());
            alertCaseProducer.sendMessage(alertEvent);
            System.out.println("Alert sent for transaction: " + event.getTransactionId());
        }

        // Send monitoring result
        TransactionMonitoringResult result = new TransactionMonitoringResult();
        result.setTransactionId(event.getTransactionId());
        result.setStatus("FAIL".equals(response.getStatus()) ? "SUSPENDED" : "CLEAR");
        result.setReason(response.getReason());
        transactionMonitoringResultProducer.sendMessage(result);

        // Gửi ack xác nhận đã xử lý message
        requestAckProducer.sendMessage(event);
    }

    @Transactional("neo4jTransactionManager")
    public TransactionListResponse getAllTransactions() {
        TransactionListResponse response = new TransactionListResponse();

        // Retrieve from PostgreSQL
        List<TransactionEntity> jpaTransactions = transactionJpaRepository.findAll();

        // Map JPA data
        List<TransactionInfo> transactionInfos = jpaTransactions.stream()
                .map(t -> {
                    TransactionInfo info = new TransactionInfo();
                    info.setTransactionId(t.getId());
                    info.setAmount(t.getTransactionAmount());
                    info.setDate(t.getDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                    info.setFromAccountId(t.getFromAccount());
                    info.setToAccountId(t.getToAccount());
                    info.setCountry(t.getCountry());
                    return info;
                })
                .collect(Collectors.toList());

        // Retrieve from Neo4j
        try {
            List<Transaction> neo4jTransactions = transactionRepository.findAll();
            neo4jTransactions.forEach(t -> {
                if (transactionInfos.stream().noneMatch(info -> info.getTransactionId().equals(t.getId()))) {
                    TransactionInfo info = new TransactionInfo();
                    info.setTransactionId(t.getId());
                    info.setAmount(t.getAmount());
                    info.setDate(t.getDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                    info.setFromAccountId(t.getFromAccount());
                    info.setToAccountId(t.getToAccount());
                    info.setCountry(t.getCountry());
                    transactionInfos.add(info);
                }
            });
        } catch (Exception e) {
            System.err.println("Error retrieving Neo4j transactions: " + e.getMessage());
            response.setMessage("Transactions retrieved from JPA, Neo4j failed: " + e.getMessage());
        }

        response.setTransactions(transactionInfos);
        response.setStatus("SUCCESS");
        response.setMessage("Transactions retrieved successfully");

        return response;
    }

    @Transactional
    public TransactionListResponse detectSmurfingTransactions(Long fromAccountId, Long toAccountId) {
        TransactionListResponse response = new TransactionListResponse();
        LocalDateTime endTime = LocalDateTime.now();
        LocalDateTime startTime = endTime.minusDays(7);
        List<TransactionEntity> transactions = transactionJpaRepository.findTransactionsBetweenAccounts(
                fromAccountId,
                toAccountId,
                startTime,
                endTime
        );
        List<TransactionInfo> transactionInfos = transactions.stream()
                .filter(t -> t.getTransactionAmount() < 1000L)
                .map(t -> {
                    TransactionInfo info = new TransactionInfo();
                    info.setTransactionId(t.getId());
                    info.setAmount(t.getTransactionAmount());
                    info.setDate(t.getDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                    info.setFromAccountId(t.getFromAccount());
                    info.setToAccountId(t.getToAccount());
                    info.setCountry(t.getCountry());
                    return info;
                })
                .collect(Collectors.toList());

        response.setTransactions(transactionInfos);
        response.setStatus(transactionInfos.size() > SMURFING_COUNT_THRESHOLD ? "FAIL" : "PASS");
        response.setMessage(transactionInfos.size() > SMURFING_COUNT_THRESHOLD
                ? "Potential smurfing detected: " + transactionInfos.size() + " small transactions"
                : "No smurfing detected");
        return response;
    }

    @Transactional
    public TransactionListResponse detectLargeTransactions() {
        TransactionListResponse response = new TransactionListResponse();
        List<TransactionEntity> transactions = transactionJpaRepository.findLargeTransactions(LARGE_TRANSACTION_THRESHOLD);
        List<TransactionInfo> transactionInfos = transactions.stream()
                .map(t -> {
                    TransactionInfo info = new TransactionInfo();
                    info.setTransactionId(t.getId());
                    info.setAmount(t.getTransactionAmount());
                    info.setDate(t.getDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                    info.setFromAccountId(t.getFromAccount());
                    info.setToAccountId(t.getToAccount());
                    info.setCountry(t.getCountry());
                    return info;
                })
                .collect(Collectors.toList());

        response.setTransactions(transactionInfos);
        response.setStatus(transactionInfos.isEmpty() ? "PASS" : "FAIL");
        response.setMessage(transactionInfos.isEmpty()
                ? "No large transactions detected"
                : "Large transactions detected: " + transactionInfos.size());
        return response;
    }

    @Transactional("neo4jTransactionManager")
    public TransactionListResponse detectCircularTransactions() {
        TransactionListResponse response = new TransactionListResponse();
        List<Transaction> transactions = transactionRepository.findCircularTransactions();
        List<TransactionInfo> transactionInfos = transactions.stream()
                .map(t -> {
                    TransactionInfo info = new TransactionInfo();
                    info.setTransactionId(t.getId());
                    info.setAmount(t.getAmount());
                    info.setDate(t.getDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                    info.setFromAccountId(t.getFromAccount());
                    info.setToAccountId(t.getToAccount());
                    info.setCountry(t.getCountry());
                    return info;
                })
                .collect(Collectors.toList());

        response.setTransactions(transactionInfos);
        response.setStatus(transactionInfos.isEmpty() ? "PASS" : "FAIL");
        response.setMessage(transactionInfos.isEmpty()
                ? "No circular transactions detected"
                : "Circular transactions detected: " + transactionInfos.size());
        return response;
    }

    @Transactional
    public TransactionListResponse detectHighRiskJurisdictionTransactions() {
        TransactionListResponse response = new TransactionListResponse();
        List<TransactionEntity> transactions = transactionJpaRepository.findTransactionsInHighRiskCountries(HIGH_RISK_COUNTRIES);
        List<TransactionInfo> transactionInfos = transactions.stream()
                .map(t -> {
                    TransactionInfo info = new TransactionInfo();
                    info.setTransactionId(t.getId());
                    info.setAmount(t.getTransactionAmount());
                    info.setDate(t.getDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                    info.setFromAccountId(t.getFromAccount());
                    info.setToAccountId(t.getToAccount());
                    info.setCountry(t.getCountry());
                    return info;
                })
                .collect(Collectors.toList());

        response.setTransactions(transactionInfos);
        response.setStatus(transactionInfos.isEmpty() ? "PASS" : "FAIL");
        response.setMessage(transactionInfos.isEmpty()
                ? "No high-risk jurisdiction transactions detected"
                : "High-risk jurisdiction transactions detected: " + transactionInfos.size());
        return response;
    }
}
