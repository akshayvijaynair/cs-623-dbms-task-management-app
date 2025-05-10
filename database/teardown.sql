BEGIN;

-- Drop view
DROP VIEW IF EXISTS task.locked_tasks_view;

-- Drop triggers
DROP TRIGGER IF EXISTS trg_set_updated_at_users ON "user".users;
DROP TRIGGER IF EXISTS trg_set_updated_at_user_tasks ON task.user_tasks;
DROP TRIGGER IF EXISTS trg_set_updated_at_task_histories ON task.user_task_histories;
DROP TRIGGER IF EXISTS trg_set_updated_at_task_comments ON task.user_task_comments;

-- Drop trigger function
DROP FUNCTION IF EXISTS set_updated_at;

-- Drop tables (in reverse dependency order)
DROP TABLE IF EXISTS task.user_task_comments;
DROP TABLE IF EXISTS task.user_task_histories;
DROP TABLE IF EXISTS task.user_tasks;
DROP TABLE IF EXISTS "user".users;

-- Drop enum types
DROP TYPE IF EXISTS user_task_type;
DROP TYPE IF EXISTS user_task_status;
DROP TYPE IF EXISTS user_task_priority;

-- Drop schemas
DROP SCHEMA IF EXISTS task CASCADE;
DROP SCHEMA IF EXISTS "user" CASCADE;

COMMIT;