package com.parimal.taskmanager.repository;

import com.parimal.taskmanager.model.TaskPriority;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskPriorityRepository extends JpaRepository<TaskPriority, Long> {}
