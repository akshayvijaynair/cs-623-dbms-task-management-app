package com.parimal.taskmanager.repository;

import com.parimal.taskmanager.model.TaskPriority;
import com.parimal.taskmanager.model.TaskStatus;
import com.parimal.taskmanager.model.TaskType;
import com.parimal.taskmanager.model.UserTask;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserTaskRepository extends JpaRepository<UserTask, Long> {
    @Query("SELECT t FROM UserTask t WHERE t.assignee.id = :userId")
    List<UserTask> findByAssigneeId(@Param("userId") Long userId);

    @Query("""
    SELECT t FROM UserTask t
    WHERE (:userId IS NULL OR t.user.id = :userId)
      AND (:assigneeId IS NULL OR t.assignee.id = :assigneeId)
      AND (:status IS NULL OR t.status = :status)
      AND (:priority IS NULL OR t.priority = :priority)
      AND (:type IS NULL OR t.type = :type)
""")
    List<UserTask> findByFilters(
            @Param("userId") Long userId,
            @Param("status") TaskStatus status,
            @Param("priority") TaskPriority priority,
            @Param("type") TaskType type,
            Sort sort
    );

}
