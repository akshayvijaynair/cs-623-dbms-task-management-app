package com.parimal.taskmanager.model;

import jakarta.persistence.*;

@Entity
@Table(name = "priority")
public class TaskPriority {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String level;

    // Constructors
    public TaskPriority() {}
    public TaskPriority(String level) {
        this.level = level;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }
}


