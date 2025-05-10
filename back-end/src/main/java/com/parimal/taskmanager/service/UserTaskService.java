package com.parimal.taskmanager.service;

import com.parimal.taskmanager.DTO.UpdateTaskRequest;
import com.parimal.taskmanager.model.*;
import com.parimal.taskmanager.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.time.LocalDateTime;
import java.util.List;

@Service
public class UserTaskService {

    @Autowired
    private UserTaskRepository userTaskRepo;
    @Autowired private UserRepository userRepo;
    @Autowired private TaskPriorityRepository priorityRepo;
    @Autowired private TaskStatusRepository statusRepo;
    @Autowired private TaskTypeRepository typeRepo;

    public UserTask createTask(UserTask task, Long assigneeId, Long priorityId, Long statusId, Long typeId) {
        User assignee = userRepo.findById(assigneeId)
                .orElseThrow(() -> new RuntimeException("Assignee not found"));
        TaskPriority priority = priorityRepo.findById(priorityId)
                .orElseThrow(() -> new RuntimeException("Priority not found"));
        TaskStatus status = statusRepo.findById(statusId)
                .orElseThrow(() -> new RuntimeException("Status not found"));
        TaskType type = typeRepo.findById(typeId)
                .orElseThrow(() -> new RuntimeException("Type not found"));

        task.setAssignee(assignee);
        task.setPriority(priority);
        task.setStatus(status);
        task.setType(type);

        return userTaskRepo.save(task);
    }

    public List<UserTask> getTasksByUserId(Long userId) {
        return userTaskRepo.findByAssigneeId(userId);
    }

    public UserTask updateTask(Long taskId, UpdateTaskRequest request) {
        UserTask task = userTaskRepo.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        task.setTitle(request.getTitle());
        task.setValue(request.getValue());
        task.setDueDate(request.getDueDate());

        if (request.getAssigneeId() != null) {
            User assignee = userRepo.findById(request.getAssigneeId())
                    .orElseThrow(() -> new RuntimeException("Assignee not found"));
            task.setAssignee(assignee);
        }

        if (request.getPriorityId() != null) {
            TaskPriority priority = priorityRepo.findById(request.getPriorityId())
                    .orElseThrow(() -> new RuntimeException("Priority not found"));
            task.setPriority(priority);
        }

        if (request.getStatusId() != null) {
            TaskStatus status = statusRepo.findById(request.getStatusId())
                    .orElseThrow(() -> new RuntimeException("Status not found"));
            task.setStatus(status);
        }

        if (request.getTypeId() != null) {
            TaskType type = typeRepo.findById(request.getTypeId())
                    .orElseThrow(() -> new RuntimeException("Type not found"));
            task.setType(type);
        }

        return userTaskRepo.save(task);
    }

}
