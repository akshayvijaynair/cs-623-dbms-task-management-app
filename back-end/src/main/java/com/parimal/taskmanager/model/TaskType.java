package com.parimal.taskmanager.model;

import jakarta.persistence.*;

@Entity
@Table(name = "type")
public class TaskType {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "task_type")
    private String taskType;

    // Getters and setters
}
