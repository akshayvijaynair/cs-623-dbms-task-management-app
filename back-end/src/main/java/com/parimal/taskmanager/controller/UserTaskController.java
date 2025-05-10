package com.parimal.taskmanager.controller;

import com.parimal.taskmanager.model.TaskRequest;
import com.parimal.taskmanager.model.UserTask;
import com.parimal.taskmanager.service.UserTaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

}
