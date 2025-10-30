-- Add reset token columns to users table
-- For password reset functionality

USE delivery_db;

-- Add reset token columns
ALTER TABLE users 
ADD COLUMN reset_otp VARCHAR(6) NULL COMMENT 'OTP for password reset',
ADD COLUMN reset_otp_expiry TIMESTAMP NULL COMMENT 'OTP expiry time',
ADD COLUMN reset_otp_attempts INT DEFAULT 0 COMMENT 'Number of failed OTP attempts';

-- Add index for performance
CREATE INDEX idx_reset_otp ON users(reset_otp);

-- Show the updated table structure
DESCRIBE users;

SELECT 'Reset token columns added successfully!' AS Status;
