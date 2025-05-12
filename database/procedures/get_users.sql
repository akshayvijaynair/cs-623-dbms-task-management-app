CREATE OR REPLACE FUNCTION get_users()
RETURNS TABLE (
    id INT,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
AS $$
BEGIN
RETURN QUERY
SELECT u.id, u.name, u.email, u.created_at, u.updated_at
FROM "user".users u
ORDER BY u.id;
END;
$$ LANGUAGE plpgsql;