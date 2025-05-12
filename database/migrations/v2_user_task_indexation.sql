BEGIN;

-- Index to optimize filtering by assignee_id
CREATE INDEX IF NOT EXISTS idx_user_tasks_assignee_id
    ON task.user_tasks (assignee_id);

-- Index to optimize filtering by status
CREATE INDEX IF NOT EXISTS idx_user_tasks_status
    ON task.user_tasks (status);

-- Index to optimize filtering by priority
CREATE INDEX IF NOT EXISTS idx_user_tasks_priority
    ON task.user_tasks (priority);

-- Index to optimize filtering by type
CREATE INDEX IF NOT EXISTS idx_user_tasks_type
    ON task.user_tasks (type);

-- Composite index to optimize multi-field filtering (assignee + status + priority + type)
CREATE INDEX IF NOT EXISTS idx_user_tasks_filter_combo
    ON task.user_tasks (assignee_id, status, priority, type);

-- Index to improve sorting/filtering by due_date
CREATE INDEX IF NOT EXISTS idx_user_tasks_due_date
    ON task.user_tasks (due_date);

-- Index to improve filtering by user_id (creator of task)
CREATE INDEX IF NOT EXISTS idx_user_tasks_user_id
    ON task.user_tasks (user_id);

COMMIT;