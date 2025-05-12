# Database Design

```mermaid
erDiagram
  "user.users" {
    INT id PK
    TEXT name
    TEXT email
    TIMESTAMP created_at
    TIMESTAMP updated_at
  }

  "task.user_tasks" {
    INT id PK
    INT user_id FK
    TEXT title
    TEXT value
    user_task_type type
    user_task_status status
    user_task_priority priority
    INT assignee_id FK
    INT locked_by_id FK
    TIMESTAMP due_date
    TIMESTAMP created_at
    TIMESTAMP updated_at
  }

  "task.user_task_histories" {
    INT id PK
    INT user_id FK
    INT user_task_history FK
    TEXT change
    TIMESTAMP created_at
    TIMESTAMP updated_at
  }

  "task.user_task_comments" {
    INT id PK
    INT note_id FK
    INT user_id FK
    TEXT comment
    TIMESTAMP created_at
    TIMESTAMP updated_at
  }

  "user.users" ||--o{ "task.user_tasks" : creates
  "user.users" ||--o{ "task.user_tasks" : assigned
  "user.users" ||--o{ "task.user_tasks" : locks
  "task.user_tasks" ||--o{ "task.user_task_histories" : has
  "task.user_tasks" ||--o{ "task.user_task_comments" : has
```


## Setup on postgreSQL

Prerequisites:
•	You must have pgAdmin installed and connected to your PostgreSQL server.
•	You should have appropriate permissions on the database you’re modifying.

Steps to Run the Script in pgAdmin:

1. Open pgAdmin and connect to your database
   - Launch pgAdmin.
   - Connect to your server.
   - Expand the tree view on the left: Servers > [Your Server] > Databases > [Your Database].

2. Open a Query Tool
   - Right-click on the target database (e.g., myapp_db) in the tree view.
   - Select Query Tool from the context menu.

3. Paste the SQL script
   - In the SQL editor that opens, paste the entire script (from the BEGIN; to COMMIT; block).
   - Make sure all of it is copied in one go.

4. Execute the Script
   - Click the Execute/Run button (lightning bolt icon), or press F5.
   - The message pane below should show Query returned successfully if all goes well.

5. Confirm Changes
   - Refresh your Tables list by right-clicking Tables > Refresh to verify new tables were created.
   - Optionally: Go to Views to see locked_tasks_view.
   - You can also expand Functions and Triggers to verify that set_updated_at and all triggers are present.


## Steps for database

1. execute setup.sql
2. execute test-data.sql
3. 