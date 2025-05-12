-- get tasks
SELECT * FROM task.all_tasks_view;

-- 3. getTasksAssignedToUser
SELECT * FROM get_tasks_assigned_to_user(p_user_id := 10);

-- 5. createTask
SELECT * FROM create_task(
        101,                                -- INT
        'Finish documentation'::TEXT,       -- TEXT
        'Document all endpoints'::TEXT,     -- TEXT
        'TASK'::user_task_type,             -- ENUM
        'OPEN'::user_task_status,           -- ENUM
        'HIGH'::user_task_priority,         -- ENUM
        101,                                -- INT
        NULL::INT,                          -- INT
        (CURRENT_TIMESTAMP + INTERVAL '2 days')::TIMESTAMP -- TIMESTAMP
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

UPDATE task.user_tasks
SET title = 'Updated Task Title'
WHERE id = 1;

UPDATE task.user_tasks
SET assignee_id = 10
WHERE id = 1;

UPDATE task.user_tasks
SET priority = 'HIGH'
WHERE id = 1;

UPDATE task.user_tasks
SET due_date = CURRENT_TIMESTAMP + INTERVAL '3 days'
WHERE id = 1;

UPDATE task.user_tasks
SET
    title = 'New Title',
    priority = 'URGENT',
    status = 'REVIEW'
WHERE id = 2;

SELECT * FROM task.user_task_histories
WHERE user_task_history = 1
ORDER BY created_at DESC;

SELECT * FROM task.locked_tasks_view;