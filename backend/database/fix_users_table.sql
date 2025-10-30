-- Fix users table structure
-- Add missing columns for password reset functionality

USE delivery_db;

-- Add missing columns if they don't exist
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS reset_otp VARCHAR(6) NULL,
ADD COLUMN IF NOT EXISTS reset_otp_expiry TIMESTAMP NULL,
ADD COLUMN IF NOT EXISTS reset_otp_attempts INT DEFAULT 0;

-- Add indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_reset_otp ON users(reset_otp);

-- Show the updated table structure
DESCRIBE users;

SELECT 'Users table updated successfully!' AS Status;
