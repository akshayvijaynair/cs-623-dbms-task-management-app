package com.parimal.taskmanager.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_task_comments")
public class UserTaskComment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "note_id")
    private UserTask task;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    private String comment;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // Getters and setters
}
