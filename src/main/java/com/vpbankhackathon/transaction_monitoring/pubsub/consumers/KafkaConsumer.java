/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.vpbankhackathon.transaction_monitoring.pubsub.consumers;

/**
 *
 * @author thinh
 */
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionMonitoringRequest;
import com.vpbankhackathon.transaction_monitoring.pubsub.producers.AlertCaseProducer;
import com.vpbankhackathon.transaction_monitoring.pubsub.producers.RequestAckProducer;
import com.vpbankhackathon.transaction_monitoring.service.TransactionMonitoringService;

@Component
public class KafkaConsumer {

    @Autowired
    private TransactionMonitoringService transactionMonitoringService;

    @Autowired
    RequestAckProducer requestAckProducer;

    @Autowired
    private AlertCaseProducer alertCaseProducer;

    @KafkaListener(topics = "transaction-monitoring-requests")
    public void listenTransactionRequestMsg(
            @Payload TransactionMonitoringRequest event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment acknowledgment) {

        try {
            System.out.println("Received transaction request: " + event.getCustomerId()
                    + " (ID: " + event.getTransactionId() + ") from topic: " + topic
                    + ", partition: " + partition + ", offset: " + offset);

            // Process and monitor transaction
            transactionMonitoringService.processTransactionEvent(event);
            acknowledgment.acknowledge();
            System.out.println("Message acknowledged successfully for transaction: " + event.getTransactionId());

        } catch (Exception e) {
            System.err.println("Error processing transaction request: " + e.getMessage());
            e.printStackTrace();

            // Acknowledge message even on error to prevent infinite retries
            acknowledgment.acknowledge();
            System.out.println("Message acknowledged after error for transaction: " + event.getTransactionId());
        }
    }
}
