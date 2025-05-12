-- get tasks
SELECT * FROM get_tasks();

-- 3. getTasksAssignedToUser
SELECT * FROM get_tasks_assigned_to_user(p_user_id := 10);

-- 5. createTask
SELECT * FROM create_task(
        p_user_id := 101,
        p_title := 'Finish documentation',
        p_value := 'Document all endpoints in OpenAPI format',
        p_type := 'TASK'::user_task_type,
        p_status := 'OPEN'::user_task_status,
        p_priority := 'HIGH'::user_task_priority,
        p_assignee_id := 101,
        p_locked_by_id := NULL,
        p_due_date := CURRENT_TIMESTAMP + INTERVAL '2 days'
              );

-- 6. createTaskComment
SELECT * FROM create_task_comment(
        p_note_id := 1,
        p_user_id := 3,
        p_comment := 'Please review the docs'
              );

-- 7. createTaskHistory
SELECT * FROM create_task_history(
        p_user_id := 99,
        p_task_id := 1,
        p_change := 'Changed status from TODO to WIP'
              );

-- 8. getTaskWithCommentsAndHistory
SELECT * FROM get_task_with_comments_and_history(p_task_id := 1);