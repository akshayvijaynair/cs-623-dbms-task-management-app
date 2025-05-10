package com.parimal.taskmanager.DTO;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UpdateTaskRequest {
    private String title;
    private String value;
    private LocalDateTime dueDate;
    private Long assigneeId;
    private Long priorityId;
    private Long statusId;
    private Long typeId;
}
