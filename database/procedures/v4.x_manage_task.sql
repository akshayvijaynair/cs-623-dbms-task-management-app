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
    -- Create the task
    INSERT INTO task.user_tasks (
        user_id, title, value, type, status, priority, assignee_id, locked_by_id, due_date
    ) VALUES (
                 p_user_id, p_title, p_value, p_type, p_status, p_priority, p_assignee_id, p_locked_by_id, p_due_date
             )
    RETURNING * INTO new_task;

    -- Log task creation in history
    INSERT INTO task.user_task_histories (user_id, user_task_history, change)
    VALUES (p_user_id, new_task.id, 'Task created with title "' || new_task.title || '"');

    RETURN new_task;
END;
$$ LANGUAGE plpgsql;


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

-- Drop if already exists
DROP FUNCTION IF EXISTS delete_task(INT);

-- Stored procedure to delete a task by ID (cascades to comments and history)
CREATE OR REPLACE FUNCTION delete_task(p_task_id INT)
    RETURNS VOID
AS $$
BEGIN
    -- First, verify the task exists
    IF NOT EXISTS (
        SELECT 1 FROM task.user_tasks WHERE id = p_task_id
    ) THEN
        RAISE EXCEPTION 'Task with ID % does not exist', p_task_id;
    END IF;

    -- Delete the task; comments and histories are automatically deleted via ON DELETE CASCADE
    DELETE FROM task.user_tasks
    WHERE id = p_task_id;
END;
$$ LANGUAGE plpgsql;

-- update task
DROP FUNCTION IF EXISTS update_task(INT, INT, TEXT, TEXT, user_task_type, user_task_status, user_task_priority, INT, INT, TIMESTAMP);

CREATE OR REPLACE FUNCTION update_task(
    p_task_id INT,
    p_user_id INT,
    p_title TEXT DEFAULT NULL,
    p_value TEXT DEFAULT NULL,
    p_type user_task_type DEFAULT NULL,
    p_status user_task_status DEFAULT NULL,
    p_priority user_task_priority DEFAULT NULL,
    p_assignee_id INT DEFAULT NULL,
    p_locked_by_id INT DEFAULT NULL,
    p_due_date TIMESTAMP DEFAULT NULL
)
    RETURNS task.user_tasks
AS $$
DECLARE
    original task.user_tasks;
BEGIN
    SELECT * INTO original FROM task.user_tasks WHERE id = p_task_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Task with ID % not found', p_task_id;
    END IF;

    -- 🔒 Check if task is locked by someone else
    IF original.locked_by_id IS NOT NULL AND original.locked_by_id != p_user_id THEN
        RAISE EXCEPTION 'Task % is locked by user ID %, not user ID %',
            p_task_id, original.locked_by_id, p_user_id;
    END IF;

    -- 📝 Audit logging
    IF p_title IS NOT NULL AND p_title != original.title THEN
        PERFORM create_task_history(p_user_id, p_task_id, 'Changed title from "' || original.title || '" to "' || p_title || '"');
    END IF;

    IF p_value IS NOT NULL AND p_value != original.value THEN
        PERFORM create_task_history(p_user_id, p_task_id, 'Changed value from "' || original.value || '" to "' || p_value || '"');
    END IF;

    IF p_type IS NOT NULL AND p_type != original.type THEN
        PERFORM create_task_history(p_user_id, p_task_id, 'Changed type from "' || original.type || '" to "' || p_type || '"');
    END IF;

    IF p_status IS NOT NULL AND p_status != original.status THEN
        PERFORM create_task_history(p_user_id, p_task_id, 'Changed status from "' || original.status || '" to "' || p_status || '"');
    END IF;

    IF p_priority IS NOT NULL AND p_priority != original.priority THEN
        PERFORM create_task_history(p_user_id, p_task_id, 'Changed priority from "' || original.priority || '" to "' || p_priority || '"');
    END IF;

    IF p_assignee_id IS NOT NULL AND p_assignee_id != original.assignee_id THEN
        PERFORM create_task_history(p_user_id, p_task_id, 'Changed assignee_id from "' || original.assignee_id || '" to "' || p_assignee_id || '"');
    END IF;

    IF p_due_date IS NOT NULL AND p_due_date != original.due_date THEN
        PERFORM create_task_history(p_user_id, p_task_id, 'Changed due_date from "' || original.due_date || '" to "' || p_due_date || '"');
    END IF;

    -- ✅ Perform update and unlock the task
    UPDATE task.user_tasks
    SET
        title = COALESCE(p_title, original.title),
        value = COALESCE(p_value, original.value),
        type = COALESCE(p_type, original.type),
        status = COALESCE(p_status, original.status),
        priority = COALESCE(p_priority, original.priority),
        assignee_id = COALESCE(p_assignee_id, original.assignee_id),
        locked_by_id = NULL,  -- 🔓 Automatically unlock after update
        due_date = COALESCE(p_due_date, original.due_date)
    WHERE id = p_task_id;

    RETURN (SELECT * FROM task.user_tasks WHERE id = p_task_id);
END;
$$ LANGUAGE plpgsql;