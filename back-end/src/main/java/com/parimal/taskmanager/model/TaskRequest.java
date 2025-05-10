package com.parimal.taskmanager.model;

import java.time.LocalDateTime;

public class TaskRequest {
    private String title;
    private String value;
    private LocalDateTime dueDate;

    private Long assigneeId;
    private Long priorityId;
    private Long statusId;
    private Long typeId;

    // Getters and Setters
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }

    public LocalDateTime getDueDate() { return dueDate; }
    public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }

    public Long getAssigneeId() { return assigneeId; }
    public void setAssigneeId(Long assigneeId) { this.assigneeId = assigneeId; }

    public Long getPriorityId() { return priorityId; }
    public void setPriorityId(Long priorityId) { this.priorityId = priorityId; }

    public Long getStatusId() { return statusId; }
    public void setStatusId(Long statusId) { this.statusId = statusId; }

    public Long getTypeId() { return typeId; }
    public void setTypeId(Long typeId) { this.typeId = typeId; }
}
