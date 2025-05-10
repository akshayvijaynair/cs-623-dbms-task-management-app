package com.parimal.taskmanager.repository;

import com.parimal.taskmanager.model.UserTask;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserTaskRepository extends JpaRepository<UserTask, Long> {
    List<UserTask> findByAssigneeId(Long userId);

}
