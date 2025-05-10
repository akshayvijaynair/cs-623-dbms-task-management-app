package com.parimal.taskmanager.repository;

import com.parimal.taskmanager.model.TaskType;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskTypeRepository extends JpaRepository<TaskType, Long> {}
