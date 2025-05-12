package com.parimal.taskmanager.controller;

import com.parimal.taskmanager.model.TaskHistory;
import com.parimal.taskmanager.repository.TaskHistoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/history")
public class TaskHistoryController {

    @Autowired
    private TaskHistoryRepository historyRepo;

    @GetMapping("/{taskId}")
    public ResponseEntity<List<TaskHistory>> getTaskHistory(@PathVariable Long taskId) {
        List<TaskHistory> history = historyRepo.findByTaskId(taskId);
        return ResponseEntity.ok(history);
    }
}
