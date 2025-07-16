package com.vpbankhackathon.transaction_monitoring.models.entities;

import java.time.OffsetDateTime;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;
import org.springframework.data.neo4j.core.schema.Relationship;

import lombok.Data;

@Node
@Data
public class Transaction {

    @Id
    @GeneratedValue
    private Long id;
    private Long amount;
    private OffsetDateTime date;
    private String country;

    @Relationship(type = "FROM_ACCOUNT", direction = Relationship.Direction.OUTGOING)
    private Account fromAccount;

    @Relationship(type = "TO_ACCOUNT", direction = Relationship.Direction.OUTGOING)
    private Account toAccount;
//    @Id
//    @GeneratedValue
//    private String transactionId;
//    private String customerId;
//    private String customerName;
//    private String customerIdentificationNumber;
//    private double amount;
//    private String currency;
//    @Relationship(type = "FROM_ACCOUNT", direction = Relationship.Direction.OUTGOING)
//    private String sourceAccountNumber;
//    @Relationship(type = "TO_ACCOUNT", direction = Relationship.Direction.OUTGOING)
//    private String destinationAccountNumber;
//    private OffsetDateTime date;
//    private Long timestamp;
}
