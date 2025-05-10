package com.parimal.taskmanager.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_task_histories")
public class UserTaskHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "user_task_history")
    private UserTask task;

    private String change;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // Getters and setters
}
