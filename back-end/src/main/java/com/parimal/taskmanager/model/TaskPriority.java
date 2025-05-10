package com.parimal.taskmanager.model;

import jakarta.persistence.*;

@Entity
@Table(name = "priority")
public class TaskPriority {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "priority_level")
    private String priorityLevel;

    // Getters and setters
}
