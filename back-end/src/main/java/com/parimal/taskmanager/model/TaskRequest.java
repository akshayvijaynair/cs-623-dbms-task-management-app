package com.parimal.taskmanager.model;

import java.time.LocalDateTime;

public class TaskRequest {

    private String title;
    private String value;
    private LocalDateTime dueDate;

    private Long assigneeId;
    private TaskPriority priority;
    private TaskStatus status;
    private TaskType type;

    // Getters and Setters
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }

    public LocalDateTime getDueDate() { return dueDate; }
    public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }

    public Long getAssigneeId() { return assigneeId; }
    public void setAssigneeId(Long assigneeId) { this.assigneeId = assigneeId; }

    public TaskPriority getPriority() { return priority; }
    public void setPriority(TaskPriority priority) { this.priority = priority; }

    public TaskStatus getStatus() { return status; }
    public void setStatus(TaskStatus status) { this.status = status; }

    public TaskType getType() { return type; }
    public void setType(TaskType type) { this.type = type; }
}