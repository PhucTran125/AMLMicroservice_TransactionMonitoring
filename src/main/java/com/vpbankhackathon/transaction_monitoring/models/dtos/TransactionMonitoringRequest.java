package com.vpbankhackathon.transaction_monitoring.models.dtos;


import lombok.Data;

import java.time.LocalDateTime;

@Data
public class TransactionMonitoringRequest {
    private Long transactionId;
    private String customerId;
    private String customerName;
    private String customerIdentificationNumber;
    private Long amount;
    private String currency;
    private Long sourceAccountNumber;
    private Long destinationAccountNumber;
    private LocalDateTime date;
    private String country;
    private Long timestamp;
    private String requestId;
}