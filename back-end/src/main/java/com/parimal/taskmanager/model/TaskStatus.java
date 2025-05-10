package com.parimal.taskmanager.model;

import jakarta.persistence.*;

@Entity
@Table(name = "status")
public class TaskStatus {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    public TaskStatus() {
        // Default constructor for JPA
    }

    public TaskStatus(String name) {
        this.name = name;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
