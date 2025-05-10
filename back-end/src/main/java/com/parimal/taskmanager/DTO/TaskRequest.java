package com.parimal.taskmanager.DTO;

import lombok.Data;

import java.time.LocalDate;

@Data
public class TaskRequest {
    private String title;
    private String value;
    private LocalDate dueDate;
    private Long priorityId;
    private Long statusId;
    private Long typeId;
    private Long assigneeId;
}

