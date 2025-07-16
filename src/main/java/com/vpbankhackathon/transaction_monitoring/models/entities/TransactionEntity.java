package com.vpbankhackathon.transaction_monitoring.models.entities;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "transactions")
@Data
public class TransactionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "transactionamount")
    private Long transactionAmount;

    @Column
    private LocalDateTime date;

    @Column
    private String country;

    @Column(name = "fromaccount")
    private Long fromAccount;

    @Column(name = "toaccount")
    private Long toAccount;

    @Column(name = "issuspicioustransaction")
    private Boolean isSuspiciousTransaction = false;

    @Column(name = "isconfirmedmoneylaundering")
    private Boolean isConfirmedMoneyLaundering = false;

    public Long getTransactionAmount() {
        return transactionAmount;
    }

    public void setTransactionAmount(Long transactionAmount) {
        this.transactionAmount = transactionAmount;
    }
}
