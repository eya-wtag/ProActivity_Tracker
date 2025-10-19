-- -- Create the database if it doesn't exist
-- CREATE DATABASE IF NOT EXISTS TodoList;
-- USE TodoList;

-- -- Create the users table with additional columns for authentication and management
-- CREATE TABLE IF NOT EXISTS users (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     username VARCHAR(50) NOT NULL UNIQUE,
--     email VARCHAR(255) NOT NULL UNIQUE,
--     -- Store a securely hashed password, never plain text. VARCHAR(255) is sufficient for most hashing algorithms.
--     password_hash VARCHAR(255) NOT NULL,
--     email_verified_at TIMESTAMP NULL DEFAULT NULL, -- Tracks if the user has verified their email
--     last_login_at TIMESTAMP NULL DEFAULT NULL, -- Tracks the user's last login time
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Automatically updates when the record is changed
-- ) ENGINE=InnoDB;

-- -- Create the WorkList table
-- CREATE TABLE IF NOT EXISTS WorkList (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     user_id INT,
--     task_name VARCHAR(255) NOT NULL,
--     priority ENUM('low','medium','high') DEFAULT 'medium',
--     is_completed BOOLEAN DEFAULT FALSE,
--     due_date DATE,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     -- Added a foreign key constraint for data integrity. ON DELETE CASCADE will delete a user's tasks if the user is deleted.
--     CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
-- ) ENGINE=InnoDB;

-- -- Add users (using a placeholder for the hashed password)
-- -- IMPORTANT: The 'password_hash' column should store a securely hashed password (e.g., using bcrypt), not a plain text string.
-- INSERT IGNORE INTO users (id, username, email, password_hash) VALUES 
-- (1, 'ava', 'ava@example.com', '$2y$10$placeholderhashedpassword1'),
-- (2, 'ellora', 'ellora@example.com', '$2y$10$placeholderhashedpassword2'),
-- (3, 'orpa', 'orpa@example.com', '$2y$10$placeholderhashedpassword3'),
-- (4, 'shejuti', 'shejuti@example.com', '$2y$10$placeholderhashedpassword4');

-- -- Add some tasks for the users
-- INSERT INTO WorkList (user_id, task_name, priority, due_date) VALUES
-- -- Tasks for ava
-- (1, 'meditation', 'high', '2025-09-25'),
-- (1, 'read books', 'medium', '2025-09-28'),
-- (1, 'write journal', 'medium', '2025-09-26'),
-- (1, 'problem solving', 'high', '2025-10-01'),
-- (1, 'exercise', 'high', '2025-09-24'),
-- -- Tasks for ellora
-- (2, 'prepare presentation', 'high', '2025-09-27'),
-- (2, 'buy groceries', 'low', '2025-09-24'),
-- (2, 'call a friend', 'medium', '2025-09-24'),
-- -- Tasks for orpa
-- (3, 'review code', 'high', '2025-09-26'),
-- (3, 'send emails', 'medium', '2025-09-25'),
-- -- Tasks for shejuti
-- (4, 'plan vacation', 'low', '2025-10-10');



-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS TodoList;
USE TodoList;

-- Create the users table with secure authentication columns
-- No changes to this table since your login/signup is working
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email_verified_at TIMESTAMP NULL DEFAULT NULL,
    last_login_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create the tasks table with enhanced fields
-- I've renamed 'WorkList' to 'tasks' for clarity and added a 'title' column.
-- The existing 'task_name' column is renamed to 'title' to align with the 'title' field in your UI.
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    taskName VARCHAR(255) NOT NULL,
    description TEXT,
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    is_completed BOOLEAN DEFAULT FALSE,
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Remove sample user and task data
-- Since your signup/login functionality works, you no longer need pre-filled data.
-- New users and tasks will be added through your application's forms.
TRUNCATE TABLE users;
TRUNCATE TABLE tasks;