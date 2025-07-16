package com.vpbankhackathon.transaction_monitoring.pubsub.producers;

import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionMonitoringRequest;
import org.apache.kafka.common.protocol.types.Field;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Component;

import java.util.concurrent.CompletableFuture;

@Component
public class RequestAckProducer {
    @Autowired
    KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${spring.kafka.producer.topic.request-ack}")
    private String topicName;

    public void sendMessage(TransactionMonitoringRequest request) {
        try {
            System.out.println("Attempting to send message to topic: " + topicName);

            CompletableFuture<SendResult<String, Object>> future = kafkaTemplate.send(topicName,
                request.getRequestId(), request.getRequestId());
            future.whenComplete((result, ex) -> {
                if (ex == null) {
                    System.out.println("Sent message for request=[" + request.getRequestId() +
                        "] with offset=[" + result.getRecordMetadata().offset() + "]");
                } else {
                    System.err.println("Unable to send message for request=[" +
                        request.getRequestId() + "] due to : " + ex.getMessage());
                }
            });
        } catch (Exception e) {
            System.err.println("Error in sendMessage: " + e.getMessage());
            throw new RuntimeException("Failed to send message to Kafka", e);
        }
    }
}
