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
    @Autowired private TaskPriorityRepository priorityRepo;
    @Autowired private TaskStatusRepository statusRepo;
    @Autowired private TaskTypeRepository typeRepo;
    @Autowired private TaskHistoryRepository taskHistoryRepo;

    public String getAuthenticatedUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null ? authentication.getName() : "system";
    }

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

        String oldTitle = task.getTitle();
        String newTitle = request.getTitle();

        // Only log history if changed
        if (newTitle != null && !newTitle.equals(oldTitle)) {
            TaskHistory history = new TaskHistory();
            history.setTask(task);
            history.setFieldChanged("title");
            history.setOldValue(oldTitle);
            history.setNewValue(newTitle);
            history.setChangedAt(LocalDateTime.now());
            history.setChangedBy(task.getAssignee()); // Optional: replace with authenticated user if available

            taskHistoryRepo.save(history);
            task.setTitle(newTitle); // update only after saving history
        }

        // Continue updating other fields
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


    public void deleteTask(Long taskId) {
        if (!userTaskRepo.existsById(taskId)) {
            throw new RuntimeException("Task not found");
        }
        userTaskRepo.deleteById(taskId);
    }

    public List<UserTask> filterAndSortTasks(Long userId, Long statusId, Long priorityId, Long typeId, String sortBy, String sortDir) {
        return userTaskRepo.findByFilters(userId, statusId, priorityId, typeId, Sort.by(Sort.Direction.fromString(sortDir), sortBy));
    }




}
