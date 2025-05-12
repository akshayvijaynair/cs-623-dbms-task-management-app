BEGIN;
-- trigger to auto-update task_histories table
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


-- Trigger function to log deletes on task_histories table
CREATE OR REPLACE FUNCTION task.log_user_task_delete()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO task.user_task_histories (user_id, user_task_history, change)
    VALUES (OLD.assignee_id, OLD.id, 'Task deleted: "' || COALESCE(OLD.title, 'Untitled') || '"');

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- execute trigger on task update
DROP TRIGGER IF EXISTS trg_log_user_task_changes ON task.user_tasks;

CREATE TRIGGER trg_log_user_task_changes
    AFTER UPDATE ON task.user_tasks
    FOR EACH ROW
EXECUTE FUNCTION task.log_user_task_update();

-- execute trigger on task delete
DROP TRIGGER IF EXISTS trg_log_user_task_deletes ON task.user_tasks;

CREATE TRIGGER trg_log_user_task_deletes
    BEFORE DELETE ON task.user_tasks
    FOR EACH ROW
EXECUTE FUNCTION task.log_user_task_delete();

COMMIT;