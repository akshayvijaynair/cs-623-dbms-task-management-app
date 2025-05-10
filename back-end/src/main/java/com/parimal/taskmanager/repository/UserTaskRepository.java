package com.parimal.taskmanager.repository;

import com.parimal.taskmanager.model.UserTask;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserTaskRepository extends JpaRepository<UserTask, Long> {
}
