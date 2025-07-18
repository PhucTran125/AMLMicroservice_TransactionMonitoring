package com.vpbankhackathon.transaction_monitoring;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TransactionMonitoringApplication {

    public static void main(String[] args) {
        // Set JVM properties for Neo4j compatibility with Java 21+
        // This handles cases where JVM arguments aren't passed externally
        if (!isModuleOpeningEnabled()) {
            System.err.println("Warning: Module system restrictions detected. " +
                    "Consider running with JVM arguments: " +
                    "--add-opens=java.base/java.lang=ALL-UNNAMED " +
                    "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED " +
                    "--add-opens=java.base/java.time=ALL-UNNAMED " +
                    "--add-opens=java.base/java.util=ALL-UNNAMED");
        }

        SpringApplication.run(TransactionMonitoringApplication.class, args);
    }

    private static boolean isModuleOpeningEnabled() {
        try {
            // Test if we can access Long.value field (what Neo4j needs)
            java.lang.reflect.Field field = Long.class.getDeclaredField("value");
            field.setAccessible(true);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
