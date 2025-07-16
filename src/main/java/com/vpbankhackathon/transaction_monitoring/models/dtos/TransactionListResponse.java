/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.vpbankhackathon.transaction_monitoring.models.dtos;

import java.util.List;

import lombok.Data;

/**
 *
 * @author thinh
 */
@Data
public class TransactionListResponse {

    private List<TransactionInfo> transactions;
    private String status; // SUCCESS or FAIL
    private String message;
}
