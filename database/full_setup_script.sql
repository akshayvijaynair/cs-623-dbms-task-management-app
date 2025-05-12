BEGIN;

-- ===================
-- SCHEMAS AND ENUMS
-- ===================
CREATE SCHEMA IF NOT EXISTS "user";
CREATE SCHEMA IF NOT EXISTS "task";

CREATE TYPE user_task_type AS ENUM ('TASK', 'NOTES', 'QUERY', 'BLOCKER');
CREATE TYPE user_task_status AS ENUM ('OPEN', 'TODO', 'WIP', 'REVIEW', 'DONE', 'CLOSED');
CREATE TYPE user_task_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- ===================
-- TABLE DEFINITIONS
-- ===================
CREATE TABLE "user".users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task.user_tasks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES "user".users(id) ON DELETE CASCADE,
    title TEXT DEFAULT 'Untitled',
    value TEXT,
    type user_task_type NOT NULL,
    status user_task_status DEFAULT 'OPEN',
    priority user_task_priority DEFAULT 'MEDIUM',
    assignee_id INTEGER REFERENCES "user".users(id) ON DELETE SET NULL,
    locked_by_id INTEGER REFERENCES "user".users(id) ON DELETE SET NULL,
    due_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task.user_task_histories (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES "user".users(id) ON DELETE SET NULL,
    user_task_history INTEGER REFERENCES task.user_tasks(id) ON DELETE CASCADE,
    change TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task.user_task_comments (
    id SERIAL PRIMARY KEY,
    note_id INTEGER REFERENCES task.user_tasks(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES "user".users(id) ON DELETE SET NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===================
-- TRIGGER FUNCTION
-- ===================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===================
-- TRIGGERS FOR UPDATED_AT
-- ===================
CREATE TRIGGER trg_set_updated_at_users
    BEFORE UPDATE ON "user".users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_set_updated_at_user_tasks
    BEFORE UPDATE ON task.user_tasks
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_set_updated_at_task_histories
    BEFORE UPDATE ON task.user_task_histories
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_set_updated_at_task_comments
    BEFORE UPDATE ON task.user_task_comments
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ===================
-- VIEWS
-- ===================
CREATE OR REPLACE VIEW task.locked_tasks_view AS
SELECT
    t.id AS task_id,
    t.title,
    t.locked_by_id,
    u.name AS locked_by_name,
    t.updated_at
FROM task.user_tasks t
JOIN "user".users u ON t.locked_by_id = u.id
WHERE t.locked_by_id IS NOT NULL;

CREATE OR REPLACE VIEW "user".active_users_view AS
SELECT
    id,
    name,
    email,
    created_at,
    updated_at
FROM "user".users
WHERE is_deleted = FALSE
ORDER BY id;

CREATE OR REPLACE VIEW task.all_tasks_view AS
SELECT *
FROM task.user_tasks
ORDER BY id;

COMMIT;

-- ===================
-- INDEXES
-- ===================
BEGIN;

CREATE INDEX IF NOT EXISTS idx_user_tasks_assignee_id ON task.user_tasks (assignee_id);
CREATE INDEX IF NOT EXISTS idx_user_tasks_status ON task.user_tasks (status);
CREATE INDEX IF NOT EXISTS idx_user_tasks_priority ON task.user_tasks (priority);
CREATE INDEX IF NOT EXISTS idx_user_tasks_type ON task.user_tasks (type);
CREATE INDEX IF NOT EXISTS idx_user_tasks_filter_combo ON task.user_tasks (assignee_id, status, priority, type);
CREATE INDEX IF NOT EXISTS idx_user_tasks_due_date ON task.user_tasks (due_date);
CREATE INDEX IF NOT EXISTS idx_user_tasks_user_id ON task.user_tasks (user_id);

COMMIT;

-- ===================
-- FUNCTIONS AND PROCEDURES
-- ===================

-- === User Functions ===
CREATE OR REPLACE FUNCTION get_users()
RETURNS TABLE (
    id INT,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name, u.email, u.created_at, u.updated_at
    FROM "user".users u
    WHERE is_deleted = FALSE
    ORDER BY u.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_user(p_name TEXT, p_email TEXT)
RETURNS "user".users AS $$
DECLARE new_user "user".users;
BEGIN
    INSERT INTO "user".users (name, email)
    VALUES (p_name, p_email)
    RETURNING * INTO new_user;
    RETURN new_user;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION edit_user(p_id INT, p_name TEXT DEFAULT NULL, p_email TEXT DEFAULT NULL)
RETURNS "user".users AS $$
DECLARE existing_user "user".users;
BEGIN
    SELECT * INTO existing_user
    FROM "user".users
    WHERE id = p_id AND is_deleted = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User with ID % not found or deleted', p_id;
    END IF;
    UPDATE "user".users
    SET
        name = COALESCE(p_name, existing_user.name),
        email = COALESCE(p_email, existing_user.email),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_id
    RETURNING * INTO existing_user;
    RETURN existing_user;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_user(p_id INT)
RETURNS VOID AS $$
BEGIN
    UPDATE "user".users
    SET is_deleted = TRUE,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User with ID % not found or already deleted', p_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- === Task Functions ===
CREATE OR REPLACE FUNCTION get_tasks()
RETURNS SETOF task.user_tasks AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM task.user_tasks ORDER BY id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tasks_assigned_to_user(p_user_id INT)
RETURNS SETOF task.user_tasks AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM task.user_tasks
    WHERE assignee_id = p_user_id
    ORDER BY due_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_task_with_comments_and_history(p_task_id INT)
RETURNS TABLE (
    task_id INT, title TEXT, value TEXT, type user_task_type,
    status user_task_status, priority user_task_priority,
    assignee_id INT, locked_by_id INT, due_date TIMESTAMP,
    created_at TIMESTAMP, updated_at TIMESTAMP,
    comment_id INT, comment_user_id INT, comment TEXT, comment_created_at TIMESTAMP,
    history_id INT, history_user_id INT, change TEXT, history_created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.title, t.value, t.type, t.status, t.priority,
           t.assignee_id, t.locked_by_id, t.due_date,
           t.created_at, t.updated_at,
           c.id, c.user_id, c.comment, c.created_at,
           h.id, h.user_id, h.change, h.created_at
    FROM task.user_tasks t
    LEFT JOIN task.user_task_comments c ON t.id = c.note_id
    LEFT JOIN task.user_task_histories h ON t.id = h.user_task_history
    WHERE t.id = p_task_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_task(
    p_user_id INT, p_title TEXT, p_value TEXT, p_type user_task_type,
    p_status user_task_status, p_priority user_task_priority,
    p_assignee_id INT, p_locked_by_id INT, p_due_date TIMESTAMP
) RETURNS task.user_tasks AS $$
DECLARE new_task task.user_tasks;
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

CREATE OR REPLACE FUNCTION create_task_comment(p_note_id INT, p_user_id INT, p_comment TEXT)
RETURNS task.user_task_comments AS $$
DECLARE new_comment task.user_task_comments;
BEGIN
    INSERT INTO task.user_task_comments (note_id, user_id, comment)
    VALUES (p_note_id, p_user_id, p_comment)
    RETURNING * INTO new_comment;
    RETURN new_comment;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_task_history(p_user_id INT, p_task_id INT, p_change TEXT)
RETURNS task.user_task_histories AS $$
DECLARE new_history task.user_task_histories;
BEGIN
    INSERT INTO task.user_task_histories (user_id, user_task_history, change)
    VALUES (p_user_id, p_task_id, p_change)
    RETURNING * INTO new_history;
    RETURN new_history;
END;
$$ LANGUAGE plpgsql;


-- === Update Task Function ===
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
) RETURNS task.user_tasks AS $$
DECLARE
    original task.user_tasks;
BEGIN
    SELECT * INTO original FROM task.user_tasks WHERE id = p_task_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Task with ID % not found', p_task_id;
    END IF;

    IF original.locked_by_id IS NOT NULL AND original.locked_by_id != p_user_id THEN
        RAISE EXCEPTION 'Task % is locked by user ID %, not user ID %',
            p_task_id, original.locked_by_id, p_user_id;
    END IF;

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

    UPDATE task.user_tasks
    SET
        title = COALESCE(p_title, original.title),
        value = COALESCE(p_value, original.value),
        type = COALESCE(p_type, original.type),
        status = COALESCE(p_status, original.status),
        priority = COALESCE(p_priority, original.priority),
        assignee_id = COALESCE(p_assignee_id, original.assignee_id),
        locked_by_id = NULL,
        due_date = COALESCE(p_due_date, original.due_date)
    WHERE id = p_task_id;

    RETURN (SELECT * FROM task.user_tasks WHERE id = p_task_id);
END;
$$ LANGUAGE plpgsql;

-- === Delete Task Function ===
CREATE OR REPLACE FUNCTION delete_task(p_task_id INT)
RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM task.user_tasks WHERE id = p_task_id) THEN
        RAISE EXCEPTION 'Task with ID % does not exist', p_task_id;
    END IF;
    DELETE FROM task.user_tasks WHERE id = p_task_id;
END;
$$ LANGUAGE plpgsql;

-- === Triggers for Auto-Audit ===
BEGIN;

CREATE OR REPLACE FUNCTION task.log_user_task_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.title IS DISTINCT FROM OLD.title THEN
        INSERT INTO task.user_task_histories (user_id, user_task_history, change)
        VALUES (NEW.assignee_id, OLD.id, 'Title changed from "' || COALESCE(OLD.title, '') || '" to "' || COALESCE(NEW.title, '') || '"');
    END IF;
    IF NEW.value IS DISTINCT FROM OLD.value THEN
        INSERT INTO task.user_task_histories (user_id, user_task_history, change)
        VALUES (NEW.assignee_id, OLD.id, 'Value changed from "' || COALESCE(OLD.value, '') || '" to "' || COALESCE(NEW.value, '') || '"');
    END IF;
    IF NEW.status IS DISTINCT FROM OLD.status THEN
        INSERT INTO task.user_task_histories (user_id, user_task_history, change)
        VALUES (NEW.assignee_id, OLD.id, 'Status changed from "' || OLD.status || '" to "' || NEW.status || '"');
    END IF;
    IF NEW.priority IS DISTINCT FROM OLD.priority THEN
        INSERT INTO task.user_task_histories (user_id, user_task_history, change)
        VALUES (NEW.assignee_id, OLD.id, 'Priority changed from "' || OLD.priority || '" to "' || NEW.priority || '"');
    END IF;
    IF NEW.type IS DISTINCT FROM OLD.type THEN
        INSERT INTO task.user_task_histories (user_id, user_task_history, change)
        VALUES (NEW.assignee_id, OLD.id, 'Type changed from "' || OLD.type || '" to "' || NEW.type || '"');
    END IF;
    IF NEW.due_date IS DISTINCT FROM OLD.due_date THEN
        INSERT INTO task.user_task_histories (user_id, user_task_history, change)
        VALUES (NEW.assignee_id, OLD.id, 'Due date changed from "' || OLD.due_date || '" to "' || NEW.due_date || '"');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION task.log_user_task_delete()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO task.user_task_histories (user_id, user_task_history, change)
    VALUES (OLD.assignee_id, OLD.id, 'Task deleted: "' || COALESCE(OLD.title, 'Untitled') || '"');
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_user_task_changes ON task.user_tasks;
CREATE TRIGGER trg_log_user_task_changes
AFTER UPDATE ON task.user_tasks
FOR EACH ROW EXECUTE FUNCTION task.log_user_task_update();

DROP TRIGGER IF EXISTS trg_log_user_task_deletes ON task.user_tasks;
CREATE TRIGGER trg_log_user_task_deletes
BEFORE DELETE ON task.user_tasks
FOR EACH ROW EXECUTE FUNCTION task.log_user_task_delete();

COMMIT;
