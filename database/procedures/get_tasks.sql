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