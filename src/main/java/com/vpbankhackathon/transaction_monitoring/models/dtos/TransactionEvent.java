/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.vpbankhackathon.transaction_monitoring.models.dtos;

import java.time.LocalDateTime;

import lombok.Data;

/**
 *
 * @author thinh
 */
@Data
public class TransactionEvent {

    private Long id;
    private Long transactionAmount;
    private LocalDateTime date;
    private Long fromAccount;
    private Long toAccount;
    private String country;
}
