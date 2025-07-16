package com.vpbankhackathon.transaction_monitoring.controllers;

import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionMonitoringRequest;
import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionMonitoringResponse;
import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionListResponse;
import com.vpbankhackathon.transaction_monitoring.service.TransactionMonitoringService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/transactions/monitor")
public class TransactionMonitoringController {

    @Autowired
    private TransactionMonitoringService service;

    @PostMapping("/{id}")
    public TransactionMonitoringResponse monitorTransaction(@PathVariable Long id, @RequestBody TransactionMonitoringRequest request) {
        return service.monitorTransaction(id, request);
    }

    @GetMapping
    public TransactionListResponse getAllTransactions() {
        return service.getAllTransactions();
    }

    @GetMapping("/smurfing")
    public TransactionListResponse detectSmurfingTransactions(@RequestParam Long fromAccountId, @RequestParam Long toAccountId) {
        return service.detectSmurfingTransactions(fromAccountId, toAccountId);
    }

    @GetMapping("/large")
    public TransactionListResponse detectLargeTransactions() {
        return service.detectLargeTransactions();
    }

    @GetMapping("/circular")
    public TransactionListResponse detectCircularTransactions() {
        return service.detectCircularTransactions();
    }

    @GetMapping("/high-risk-jurisdiction")
    public TransactionListResponse detectHighRiskJurisdictionTransactions() {
        return service.detectHighRiskJurisdictionTransactions();
    }
}