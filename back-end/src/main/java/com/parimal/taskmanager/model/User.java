package com.parimal.taskmanager.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String email;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "user")
    private List<UserTask> createdTasks;

    @OneToMany(mappedBy = "assignee")
    private List<UserTask> assignedTasks;

    @OneToMany(mappedBy = "lockedBy")
    private List<UserTask> lockedTasks;

    // Getters and Setters 👇

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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<UserTask> getCreatedTasks() {
        return createdTasks;
    }

    public void setCreatedTasks(List<UserTask> createdTasks) {
        this.createdTasks = createdTasks;
    }

    public List<UserTask> getAssignedTasks() {
        return assignedTasks;
    }

    public void setAssignedTasks(List<UserTask> assignedTasks) {
        this.assignedTasks = assignedTasks;
    }

    public List<UserTask> getLockedTasks() {
        return lockedTasks;
    }

    public void setLockedTasks(List<UserTask> lockedTasks) {
        this.lockedTasks = lockedTasks;
    }
}
