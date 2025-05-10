package com.parimal.taskmanager.repository;

import com.parimal.taskmanager.model.UserTask;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UserTaskRepository extends JpaRepository<UserTask, Long> {
    List<UserTask> findByAssigneeId(Long userId);
    @Query("SELECT t FROM UserTask t WHERE " +
            "(:userId IS NULL OR t.assignee.id = :userId) AND " +
            "(:statusId IS NULL OR t.status.id = :statusId) AND " +
            "(:priorityId IS NULL OR t.priority.id = :priorityId) AND " +
            "(:typeId IS NULL OR t.type.id = :typeId)")
    List<UserTask> findByFilters(@Param("userId") Long userId,
                                 @Param("statusId") Long statusId,
                                 @Param("priorityId") Long priorityId,
                                 @Param("typeId") Long typeId,
                                 Sort sort);

}
