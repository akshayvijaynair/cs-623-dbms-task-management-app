BEGIN;

-- SCHEMAS
CREATE SCHEMA IF NOT EXISTS "user";
CREATE SCHEMA IF NOT EXISTS "task";

-- ENUM Types (in public schema, accessible globally)
CREATE TYPE user_task_type AS ENUM ('TASK', 'NOTES', 'QUERY', 'BLOCKER');
CREATE TYPE user_task_status AS ENUM ('OPEN', 'TODO', 'WIP', 'REVIEW', 'DONE', 'CLOSED');
CREATE TYPE user_task_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- user.users
CREATE TABLE "user".users (
                              id SERIAL PRIMARY KEY,
                              name TEXT NOT NULL,
                              email TEXT UNIQUE NOT NULL,
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- task.user_tasks
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

-- task.user_task_histories
CREATE TABLE task.user_task_histories (
                                          id SERIAL PRIMARY KEY,
                                          user_id INTEGER REFERENCES "user".users(id) ON DELETE SET NULL,
                                          user_task_history INTEGER REFERENCES task.user_tasks(id) ON DELETE CASCADE,
                                          change TEXT,
                                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- task.user_task_comments
CREATE TABLE task.user_task_comments (
                                         id SERIAL PRIMARY KEY,
                                         note_id INTEGER REFERENCES task.user_tasks(id) ON DELETE CASCADE,
                                         user_id INTEGER REFERENCES "user".users(id) ON DELETE SET NULL,
                                         comment TEXT,
                                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                         updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger function (in public)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
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

-- View: locked_tasks_view
CREATE OR REPLACE VIEW task.locked_tasks_view AS
SELECT
    t.id AS task_id,
    t.title,
    t.locked_by_id,
    u.name AS locked_by_name,
    t.updated_at
FROM
    task.user_tasks t
        JOIN
    "user".users u ON t.locked_by_id = u.id
WHERE
    t.locked_by_id IS NOT NULL;

COMMIT;