/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.vpbankhackathon.transaction_monitoring.repository.jpa;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.vpbankhackathon.transaction_monitoring.models.entities.TransactionEntity;

public interface TransactionJpaRepository extends JpaRepository<TransactionEntity, Long> {

    @Query("SELECT t FROM TransactionEntity t WHERE t.fromAccount = :fromAccountId AND t.toAccount = :toAccountId AND t.date >= :startTime AND t.date <= :endTime")
    List<TransactionEntity> findTransactionsBetweenAccounts(Long fromAccountId, Long toAccountId,
            LocalDateTime startTime, LocalDateTime endTime);

    @Query("SELECT t FROM TransactionEntity t WHERE t.transactionAmount > :threshold")
    List<TransactionEntity> findLargeTransactions(Long threshold);

    @Query("SELECT t FROM TransactionEntity t WHERE t.country IN :highRiskCountries")
    List<TransactionEntity> findTransactionsInHighRiskCountries(List<String> highRiskCountries);
}
