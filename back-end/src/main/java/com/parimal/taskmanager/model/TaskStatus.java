package com.parimal.taskmanager.model;

import jakarta.persistence.*;

@Entity
@Table(name = "status")
public class TaskStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "status_type")
    private String statusType;

    // Getters and setters
}
