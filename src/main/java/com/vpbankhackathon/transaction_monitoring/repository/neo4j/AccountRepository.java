/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.vpbankhackathon.transaction_monitoring.repository.neo4j;

/**
 *
 * @author thinh
 */
import com.vpbankhackathon.transaction_monitoring.models.entities.Account;
import org.springframework.data.neo4j.repository.Neo4jRepository;

public interface AccountRepository extends Neo4jRepository<Account, Long> {
}
