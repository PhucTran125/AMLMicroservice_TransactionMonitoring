package com.vpbankhackathon.transaction_monitoring.pubsub.producers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import com.vpbankhackathon.transaction_monitoring.models.dtos.AlertEvent;

@Component
public class AlertCaseRequestProducer {

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    public void sendMessage(AlertEvent event) {
        try {
            kafkaTemplate.send("alert-case-requests", event.getTransactionId().toString(), event);
            System.out.println("Sent alert for transaction: " + event.getTransactionId() + " to alert-case-requests");
        } catch (Exception e) {
            System.err.println("Error sending alert for transaction: " + event.getTransactionId() + ", error: " + e.getMessage());
        }
    }
}
