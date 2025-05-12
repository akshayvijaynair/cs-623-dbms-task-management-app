package com.parimal.taskmanager.service;

import com.parimal.taskmanager.DTO.UpdateTaskRequest;
import com.parimal.taskmanager.model.*;
import com.parimal.taskmanager.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class UserTaskService {

    @Autowired
    private UserTaskRepository userTaskRepo;
    @Autowired private UserRepository userRepo;
    @Autowired private TaskHistoryRepository taskHistoryRepo;

    public String getAuthenticatedUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null ? authentication.getName() : "system";
    }

    public List<UserTask> getAllTasks() {
        return userTaskRepo.findAll();
    }

    public UserTask createTask(UserTask task, Long assigneeId, TaskPriority priority, TaskStatus status, TaskType type) {
        User assignee = userRepo.findById(assigneeId)
                .orElseThrow(() -> new RuntimeException("Assignee not found"));

        task.setAssignee(assignee);
        task.setPriority(priority);
        task.setStatus(status);
        task.setType(type);
        task.setCreatedAt(LocalDateTime.now());
        task.setUpdatedAt(LocalDateTime.now());

        return userTaskRepo.save(task);
    }

    public List<UserTask> getTasksByUserId(Long userId) {
        return userTaskRepo.findByAssigneeId(userId);
    }

    public UserTask updateTask(Long taskId, UpdateTaskRequest request) {
        UserTask task = userTaskRepo.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        String oldTitle = task.getTitle();
        String newTitle = request.getTitle();

        if (newTitle != null && !newTitle.equals(oldTitle)) {
            TaskHistory history = new TaskHistory();
            history.setTask(task);
            history.setFieldChanged("title");
            history.setOldValue(oldTitle);
            history.setNewValue(newTitle);
            history.setChangedAt(LocalDateTime.now());
            history.setChangedBy(task.getAssignee());

            taskHistoryRepo.save(history);
            task.setTitle(newTitle);
        }

        task.setValue(request.getValue());
        task.setDueDate(request.getDueDate());
        task.setUpdatedAt(LocalDateTime.now());

        if (request.getAssigneeId() != null) {
            User assignee = userRepo.findById(request.getAssigneeId())
                    .orElseThrow(() -> new RuntimeException("Assignee not found"));
            task.setAssignee(assignee);
        }

        if (request.getPriority() != null) {
            task.setPriority(TaskPriority.valueOf(request.getPriority().toUpperCase()));
        }

        if (request.getStatus() != null) {
            task.setStatus(TaskStatus.valueOf(request.getStatus().toUpperCase()));
        }

        if (request.getType() != null) {
            task.setType(TaskType.valueOf(request.getType().toUpperCase()));
        }

        return userTaskRepo.save(task);
    }

    public void deleteTask(Long taskId) {
        if (!userTaskRepo.existsById(taskId)) {
            throw new RuntimeException("Task not found");
        }
        userTaskRepo.deleteById(taskId);
    }

    public List<UserTask> filterAndSortTasks(Long userId, TaskStatus status, TaskPriority priority, TaskType type, String sortBy, String sortDir) {
        return userTaskRepo.findByFilters(userId, status, priority, type, Sort.by(Sort.Direction.fromString(sortDir), sortBy));
    }
}