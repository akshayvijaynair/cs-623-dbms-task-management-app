package com.parimal.taskmanager.service;

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
}
