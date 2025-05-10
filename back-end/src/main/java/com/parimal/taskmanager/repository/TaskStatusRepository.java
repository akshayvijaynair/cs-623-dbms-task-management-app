package com.parimal.taskmanager.repository;

import com.parimal.taskmanager.model.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskStatusRepository extends JpaRepository<TaskStatus, Long> {}
