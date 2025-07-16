/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.vpbankhackathon.transaction_monitoring.repository.neo4j;

/**
 *
 * @author thinh
 */
import java.time.OffsetDateTime;
import java.util.List;

import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;

import com.vpbankhackathon.transaction_monitoring.models.entities.Transaction;

public interface TransactionRepository extends Neo4jRepository<Transaction, Long> {

    @Query("MATCH (t:Transaction) RETURN t")
    List<Transaction> findAll();

    @Query("MATCH (t:Transaction)-[:FROM_ACCOUNT]->(from:Account), (t)-[:TO_ACCOUNT]->(to:Account) WHERE from.id = $fromAccountId AND to.id = $toAccountId AND t.date >= $startTime AND t.date <= $endTime RETURN t")
    List<Transaction> findTransactionsBetweenAccounts(Long fromAccountId, Long toAccountId, OffsetDateTime startTime, OffsetDateTime endTime);

    @Query("MATCH (t:Transaction) WHERE t.amount > $threshold RETURN t")
    List<Transaction> findLargeTransactions(Long threshold);

    @Query("MATCH p=(t1:Transaction)-[:TO_ACCOUNT]->(a:Account)-[:FROM_ACCOUNT]->(t2:Transaction) WHERE t1.toAccount.id = t2.fromAccount.id WITH p, t1, t2 MATCH path=(t1)-[:TO_ACCOUNT|FROM_ACCOUNT*1..5]->(t3:Transaction) WHERE t3.toAccount.id = t1.fromAccount.id RETURN path")
    List<Transaction> findCircularTransactions();

    @Query("MATCH (t:Transaction) WHERE t.country IN $highRiskCountries RETURN t")
    List<Transaction> findTransactionsInHighRiskCountries(List<String> highRiskCountries);

    @Query("MERGE (t:Transaction {id: $id}) "
            + "SET t.amount = $amount, t.date = $date, t.country = $country, t.isSuspiciousTransaction = $isSuspiciousTransaction, t.isConfirmedMoneyLaundering = $isConfirmedMoneyLaundering "
            + "WITH t "
            + "MATCH (from:Account {id: $fromAccountId}), (to:Account {id: $toAccountId}) "
            + "MERGE (t)-[:FROM_ACCOUNT]->(from) "
            + "MERGE (t)-[:TO_ACCOUNT]->(to) "
            + "RETURN t")
    Transaction saveTransactionWithRelationships(Long id, Long amount, OffsetDateTime date, String country, Long fromAccountId, Long toAccountId, Boolean isSuspiciousTransaction, Boolean isConfirmedMoneyLaundering);
}
