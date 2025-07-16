/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.vpbankhackathon.transaction_monitoring.models.dtos;

import lombok.Data;

/**
 *
 * @author thinh
 */
@Data
public class TransactionInfo {

    private Long transactionId;
    private Long amount;
    private String date;
    private Long fromAccountId;
    private Long toAccountId;
    private String country;
}
