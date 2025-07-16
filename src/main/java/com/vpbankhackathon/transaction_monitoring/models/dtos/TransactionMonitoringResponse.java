/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.vpbankhackathon.transaction_monitoring.models.dtos;

/**
 *
 * @author thinh
 */
import lombok.Data;

@Data
public class TransactionMonitoringResponse {

    private Long transactionId;
    private String status; // PASS or FAIL
    private String reason;
}
