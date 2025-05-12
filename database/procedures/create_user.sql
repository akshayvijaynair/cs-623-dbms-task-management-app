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