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