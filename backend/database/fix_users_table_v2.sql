-- Fix users table structure
-- Add missing columns for password reset functionality

USE delivery_db;

-- Check and add updated_at column
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'delivery_db' 
     AND TABLE_NAME = 'users' 
     AND COLUMN_NAME = 'updated_at') = 0,
    'ALTER TABLE users ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP',
    'SELECT "updated_at column already exists" as message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add reset_otp column
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'delivery_db' 
     AND TABLE_NAME = 'users' 
     AND COLUMN_NAME = 'reset_otp') = 0,
    'ALTER TABLE users ADD COLUMN reset_otp VARCHAR(6) NULL',
    'SELECT "reset_otp column already exists" as message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add reset_otp_expiry column
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'delivery_db' 
     AND TABLE_NAME = 'users' 
     AND COLUMN_NAME = 'reset_otp_expiry') = 0,
    'ALTER TABLE users ADD COLUMN reset_otp_expiry TIMESTAMP NULL',
    'SELECT "reset_otp_expiry column already exists" as message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add reset_otp_attempts column
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'delivery_db' 
     AND TABLE_NAME = 'users' 
     AND COLUMN_NAME = 'reset_otp_attempts') = 0,
    'ALTER TABLE users ADD COLUMN reset_otp_attempts INT DEFAULT 0',
    'SELECT "reset_otp_attempts column already exists" as message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Show the updated table structure
DESCRIBE users;

SELECT 'Users table updated successfully!' AS Status;
