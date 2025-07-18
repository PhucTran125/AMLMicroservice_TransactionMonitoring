package com.vpbankhackathon.transaction_monitoring.models.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity(name = "TransactionMonitoringAccount")
@Table(name = "accounts")
@Data
public class AccountEntity {

    @Id
    private Long id;

    @Column
    private String type;

    @Column(name = "accountnumber")
    private String accountNumber;

    @Column
    private Long userId;
}
