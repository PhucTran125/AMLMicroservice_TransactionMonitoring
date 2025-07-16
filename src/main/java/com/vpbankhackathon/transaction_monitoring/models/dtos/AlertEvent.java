package com.vpbankhackathon.transaction_monitoring.models.dtos;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class AlertEvent {

    private Long transactionId;
    private String customerId;
    private Long amount;
    private LocalDateTime date;
    private String country;
    private Long sourceAccountNumber;
    private Long destinationAccountNumber;
    private String status;
    private String reason;
}
