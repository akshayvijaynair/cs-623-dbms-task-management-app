
-- getUsers
SELECT * FROM get_users();

-- createUser
SELECT * FROM create_user(p_name := 'Alice Smith', p_email := 'alice.smith@example.com');

-- Edit user with ID 5, change only the name
SELECT * FROM edit_user(p_id := 5, p_name := 'New Name');

-- Edit user with ID 7, change name and email
SELECT * FROM edit_user(p_id := 7, p_name := 'Akshay', p_email := 'akshay@example.com');

-- Delete user with ID 8
SELECT delete_user(p_id := 8);

---------- Post v3 migration --------
-- Mark user as deleted
SELECT delete_user(p_id := 5);

-- Attempting to edit a soft-deleted user raises error
SELECT * FROM edit_user(p_id := 5, p_name := 'Should Fail');

-- Filter out deleted users
SELECT * FROM "user".users WHERE is_deleted = FALSE;