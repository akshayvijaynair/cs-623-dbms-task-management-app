
-- ============================
-- STORED PROCEDURES FOR TASK SYSTEM
-- ============================

-- 1. getUsers
CREATE OR REPLACE FUNCTION get_users()
RETURNS TABLE (
    id INT,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name, u.email, u.created_at, u.updated_at
    FROM "user".users u
    ORDER BY u.id;
END;
$$ LANGUAGE plpgsql;

-- 2. getTasks
CREATE OR REPLACE FUNCTION get_tasks()
RETURNS SETOF task.user_tasks
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM task.user_tasks ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- 3. getTasksAssignedToUser
CREATE OR REPLACE FUNCTION get_tasks_assigned_to_user(p_user_id INT)
RETURNS SETOF task.user_tasks
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM task.user_tasks
    WHERE assignee_id = p_user_id
    ORDER BY due_date;
END;
$$ LANGUAGE plpgsql;

-- 4. createTask
CREATE OR REPLACE FUNCTION create_task(
    p_user_id INT,
    p_title TEXT,
    p_value TEXT,
    p_type user_task_type,
    p_status user_task_status,
    p_priority user_task_priority,
    p_assignee_id INT,
    p_locked_by_id INT,
    p_due_date TIMESTAMP
)
RETURNS task.user_tasks
AS $$
DECLARE
    new_task task.user_tasks;
BEGIN
    INSERT INTO task.user_tasks (
        user_id, title, value, type, status, priority, assignee_id, locked_by_id, due_date
    ) VALUES (
        p_user_id, p_title, p_value, p_type, p_status, p_priority, p_assignee_id, p_locked_by_id, p_due_date
    )
    RETURNING * INTO new_task;

    RETURN new_task;
END;
$$ LANGUAGE plpgsql;

-- 5. createUser
CREATE OR REPLACE FUNCTION create_user(
    p_name TEXT,
    p_email TEXT
)
RETURNS "user".users
AS $$
DECLARE
    new_user "user".users;
BEGIN
    INSERT INTO "user".users (name, email)
    VALUES (p_name, p_email)
    RETURNING * INTO new_user;

    RETURN new_user;
END;
$$ LANGUAGE plpgsql;

-- 6. createTaskComment
CREATE OR REPLACE FUNCTION create_task_comment(
    p_note_id INT,
    p_user_id INT,
    p_comment TEXT
)
RETURNS task.user_task_comments
AS $$
DECLARE
    new_comment task.user_task_comments;
BEGIN
    INSERT INTO task.user_task_comments (note_id, user_id, comment)
    VALUES (p_note_id, p_user_id, p_comment)
    RETURNING * INTO new_comment;

    RETURN new_comment;
END;
$$ LANGUAGE plpgsql;

-- 7. createTaskHistory
CREATE OR REPLACE FUNCTION create_task_history(
    p_user_id INT,
    p_task_id INT,
    p_change TEXT
)
RETURNS task.user_task_histories
AS $$
DECLARE
    new_history task.user_task_histories;
BEGIN
    INSERT INTO task.user_task_histories (user_id, user_task_history, change)
    VALUES (p_user_id, p_task_id, p_change)
    RETURNING * INTO new_history;

    RETURN new_history;
END;
$$ LANGUAGE plpgsql;

-- 8. getTaskWithCommentsAndHistory
CREATE OR REPLACE FUNCTION get_task_with_comments_and_history(p_task_id INT)
RETURNS TABLE (
    task_id INT,
    title TEXT,
    value TEXT,
    type user_task_type,
    status user_task_status,
    priority user_task_priority,
    assignee_id INT,
    locked_by_id INT,
    due_date TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    comment_id INT,
    comment_user_id INT,
    comment TEXT,
    comment_created_at TIMESTAMP,
    history_id INT,
    history_user_id INT,
    change TEXT,
    history_created_at TIMESTAMP
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id,
        t.title,
        t.value,
        t.type,
        t.status,
        t.priority,
        t.assignee_id,
        t.locked_by_id,
        t.due_date,
        t.created_at,
        t.updated_at,
        c.id,
        c.user_id,
        c.comment,
        c.created_at,
        h.id,
        h.user_id,
        h.change,
        h.created_at
    FROM task.user_tasks t
    LEFT JOIN task.user_task_comments c ON t.id = c.note_id
    LEFT JOIN task.user_task_histories h ON t.id = h.user_task_history
    WHERE t.id = p_task_id;
END;
$$ LANGUAGE plpgsql;
