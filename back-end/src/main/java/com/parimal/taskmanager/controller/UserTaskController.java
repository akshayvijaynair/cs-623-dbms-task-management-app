package com.parimal.taskmanager.controller;

import com.parimal.taskmanager.DTO.UpdateTaskRequest;
import com.parimal.taskmanager.model.TaskRequest;
import com.parimal.taskmanager.model.UserTask;
import com.parimal.taskmanager.service.UserTaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.parimal.taskmanager.DTO.UpdateTaskRequest;


import java.util.List;

@RestController
@RequestMapping("/api/tasks")
public class UserTaskController {

    @Autowired
    private UserTaskService taskService;

    @PostMapping
    public ResponseEntity<UserTask> createTask(@RequestBody TaskRequest request) {
        UserTask task = new UserTask();
        task.setTitle(request.getTitle());
        task.setValue(request.getValue());
        task.setDueDate(request.getDueDate());

        UserTask created = taskService.createTask(task, request.getAssigneeId(),
                request.getPriorityId(),
                request.getStatusId(),
                request.getTypeId());
        return ResponseEntity.ok(created);
    }

    @GetMapping("/users/{userId}/tasks")
    public ResponseEntity<List<UserTask>> getUserTasks(@PathVariable Long userId) {
        List<UserTask> tasks = taskService.getTasksByUserId(userId);
        return ResponseEntity.ok(tasks);
    }

    @PutMapping("/{taskId}")
    public ResponseEntity<UserTask> updateTask(
            @PathVariable Long taskId,
            @RequestBody UpdateTaskRequest request
    ) {
        UserTask updatedTask = taskService.updateTask(taskId, request);
        return ResponseEntity.ok(updatedTask);
    }

    @DeleteMapping("/{taskId}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long taskId) {
        taskService.deleteTask(taskId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/users/{userId}/tasks/filter")
    public ResponseEntity<List<UserTask>> filterTasks(
            @PathVariable Long userId,
            @RequestParam(required = false) Long statusId,
            @RequestParam(required = false) Long priorityId,
            @RequestParam(required = false) Long typeId,
            @RequestParam(defaultValue = "dueDate") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir
    ) {
        List<UserTask> tasks = taskService.filterAndSortTasks(userId, statusId, priorityId, typeId, sortBy, sortDir);
        return ResponseEntity.ok(tasks);
    }





}
