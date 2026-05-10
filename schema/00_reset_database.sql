-- ============================================================
-- Reset Script — drops and recreates the IAMPractice database
-- Run this whenever you want a clean slate
-- ============================================================

USE master;
GO

-- Drop all connections and delete the database
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'IAMPractice')
BEGIN
    ALTER DATABASE IAMPractice SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE IAMPractice;
END
GO

PRINT 'Database dropped. Now run 01_create_tables.sql then 02_seed_data.sql.';
