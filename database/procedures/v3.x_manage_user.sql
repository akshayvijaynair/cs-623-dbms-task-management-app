-- Create User
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


-- Edit User
CREATE OR REPLACE FUNCTION edit_user(
    p_id INT,
    p_name TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL
)
RETURNS "user".users
AS $$
DECLARE
existing_user "user".users;
BEGIN
    -- Get current user
SELECT * INTO existing_user
FROM "user".users
WHERE id = p_id;

IF NOT FOUND THEN
        RAISE EXCEPTION 'User with ID % not found', p_id;
END IF;

    -- Update with coalesce to keep existing values
UPDATE "user".users
SET
    name = CASE
               WHEN p_name IS NOT NULL THEN p_name
               ELSE existing_user.name
        END,
    email = CASE
                WHEN p_email IS NOT NULL THEN p_email
                ELSE existing_user.email
        END,
    updated_at = CURRENT_TIMESTAMP
WHERE id = p_id
    RETURNING * INTO existing_user;

RETURN existing_user;
END;
$$ LANGUAGE plpgsql;


-- Delete user
CREATE OR REPLACE FUNCTION delete_user(p_id INT)
RETURNS VOID
AS $$
BEGIN
DELETE FROM "user".users
WHERE id = p_id;

IF NOT FOUND THEN
        RAISE EXCEPTION 'User with ID % not found', p_id;
END IF;
END;
$$ LANGUAGE plpgsql;