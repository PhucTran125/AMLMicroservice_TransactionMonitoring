package com.vpbankhackathon.transaction_monitoring.models.entities;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;

import lombok.Data;

@Node("TransactionAccount")
@Data
public class Account {

    @Id
    @GeneratedValue
    private Long id;
    private Long customerId;
    private String customerName;
    private String type;
    private String accountNumber; // Thêm trường accountNumber
}
