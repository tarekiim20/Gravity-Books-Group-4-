-- Check if the database exists
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'gravity_books_dwh')
BEGIN
    -- Drop the existing database
    DROP DATABASE gravity_books_dwh;
END;

-- Create a new database
CREATE DATABASE gravity_books_dwh;
