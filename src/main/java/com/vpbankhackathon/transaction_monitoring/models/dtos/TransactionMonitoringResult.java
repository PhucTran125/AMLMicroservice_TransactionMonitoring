package com.vpbankhackathon.transaction_monitoring.models.dtos;

import lombok.Data;

@Data
public class TransactionMonitoringResult {

    private Long transactionId;
    private String status; // CLEAR or SUSPENDED or SUSPICIOUS
    private String reason;
}
