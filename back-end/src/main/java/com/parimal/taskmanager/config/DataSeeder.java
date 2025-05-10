package com.parimal.taskmanager.config;

import com.parimal.taskmanager.model.TaskPriority;
import com.parimal.taskmanager.model.TaskStatus;
import com.parimal.taskmanager.model.TaskType;
import com.parimal.taskmanager.model.User;
import com.parimal.taskmanager.repository.TaskPriorityRepository;
import com.parimal.taskmanager.repository.TaskStatusRepository;
import com.parimal.taskmanager.repository.TaskTypeRepository;
import com.parimal.taskmanager.repository.UserRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class DataSeeder {

    @Autowired
    private TaskPriorityRepository priorityRepository;

    @Autowired
    private TaskStatusRepository statusRepository;

    @Autowired
    private TaskTypeRepository typeRepository;

    @Autowired
    private UserRepository userRepository;

    @PostConstruct
    public void init() {
        seedTaskPriorities();
        seedTaskStatuses();
        seedTaskTypes();
        seedUsers();
    }

    private void seedTaskPriorities() {
        if (priorityRepository.count() == 0) {
            priorityRepository.saveAll(List.of(
                    new TaskPriority("Low"),
                    new TaskPriority("Medium"),
                    new TaskPriority("High")
            ));
        }
    }

    private void seedTaskStatuses() {
        if (statusRepository.count() == 0) {
            statusRepository.saveAll(List.of(
                    new TaskStatus("Open"),
                    new TaskStatus("In Progress"),
                    new TaskStatus("Completed")
            ));
        }
    }

    private void seedTaskTypes() {
        if (typeRepository.count() == 0) {
            typeRepository.saveAll(List.of(
                    new TaskType("Bug"),
                    new TaskType("Feature"),
                    new TaskType("Improvement")
            ));
        }
    }

    private void seedUsers() {
        if (userRepository.count() == 0) {
            userRepository.save(new User("Default User", "default@example.com"));
        }
    }
}
