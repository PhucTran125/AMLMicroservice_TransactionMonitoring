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
    private Boolean isSuspiciousTransaction = false;
    private Boolean isConfirmedMoneyLaundering = false;

    @Relationship(type = "FROM_ACCOUNT", direction = Relationship.Direction.OUTGOING)
    private Long fromAccount;

    @Relationship(type = "TO_ACCOUNT", direction = Relationship.Direction.OUTGOING)
    private Long toAccount;
}
