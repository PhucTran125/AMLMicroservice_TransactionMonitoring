package com.vpbankhackathon.transaction_monitoring.pubsub.producers;

import java.util.concurrent.CompletableFuture;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Component;

import com.vpbankhackathon.transaction_monitoring.models.dtos.TransactionMonitoringResult;

@Component
public class TransactionMonitoringResultProducer {

    @Autowired
    KafkaTemplate kafkaTemplate;

    @Value("${spring.kafka.producer.topic.transaction-monitoring-result}")
    private String topicName;

    public void sendMessage(TransactionMonitoringResult tMResult) {
        try {
            System.out.println("Attempting to send transaction monitoring result to topic: " + topicName);

            CompletableFuture<SendResult<String, Object>> future = kafkaTemplate.send(
                    topicName,
                    tMResult.getTransactionId(),
                    tMResult
            );
            future.whenComplete((result, ex) -> {
                if (ex == null) {
                    System.out.println("Sent message for transaction=[" + tMResult.getTransactionId()
                            + "] with offset=[" + result.getRecordMetadata().offset() + "]");
                } else {
                    System.err.println("Unable to send message for transaction=["
                            + tMResult.getTransactionId() + "] due to : " + ex.getMessage());
                }
            });
        } catch (Exception e) {
            System.err.println("Error in sendMessage (Transaction Monitoring Result): " + e.getMessage());
            throw new RuntimeException("Failed to send transaction monitoring result to Kafka", e);
        }
    }
}
