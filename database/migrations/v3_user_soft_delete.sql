BEGIN;

ALTER TABLE "user".users
    ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;

-- Update existing procedures (delete_user becomes a soft delete)
DROP FUNCTION IF EXISTS delete_user(INT);

CREATE OR REPLACE FUNCTION delete_user(p_id INT)
RETURNS VOID
AS $$
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

-- Update create_user and edit_user to prevent changes to soft-deleted users
DROP FUNCTION IF EXISTS edit_user(INT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION edit_user(
    p_id INT,
    p_name TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL
)
RETURNS "user".users
AS $$
DECLARE
existing_user "user".users;

BEGIN;
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
COMMIT;