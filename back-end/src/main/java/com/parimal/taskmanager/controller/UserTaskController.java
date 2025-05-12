package com.parimal.taskmanager.controller;

import com.parimal.taskmanager.DTO.UpdateTaskRequest;
import com.parimal.taskmanager.model.*;
import com.parimal.taskmanager.repository.TaskHistoryRepository;
import com.parimal.taskmanager.service.UserTaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

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

        UserTask created = taskService.createTask(
                task,
                request.getAssigneeId(),
                request.getPriority(),
                request.getStatus(),
                request.getType()
        );
        return ResponseEntity.ok(created);
    }

    @GetMapping
    public ResponseEntity<List<UserTask>> getAllTasks() {
        List<UserTask> tasks = taskService.getAllTasks();
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/{taskId}")
    public ResponseEntity<Optional<UserTask>> getAllTask(
            @PathVariable Long taskId
    ) {
        Optional<UserTask> tasks = taskService.getTask(taskId);
        return ResponseEntity.ok(tasks);
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
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String priority,
            @RequestParam(required = false) String type,
            @RequestParam(defaultValue = "dueDate") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir
    ) {
        TaskStatus statusEnum = (status != null) ? TaskStatus.valueOf(status.toUpperCase()) : null;
        TaskPriority priorityEnum = (priority != null) ? TaskPriority.valueOf(priority.toUpperCase()) : null;
        TaskType typeEnum = (type != null) ? TaskType.valueOf(type.toUpperCase()) : null;

        List<UserTask> tasks = taskService.filterAndSortTasks(
                userId,
                statusEnum,
                priorityEnum,
                typeEnum,
                sortBy,
                sortDir
        );
        return ResponseEntity.ok(tasks);
    }

    @RestController
    @RequestMapping("/api/history")
    public class TaskHistoryController {

        @Autowired
        private TaskHistoryRepository historyRepo;

        @GetMapping("/task/{taskId}")
        public ResponseEntity<List<TaskHistory>> getTaskHistory(@PathVariable Long taskId) {
            List<TaskHistory> history = historyRepo.findByTaskId(taskId);
            return ResponseEntity.ok(history);
        }
    }
}