-- Migration: Add pricing columns to orders table
-- Created: 2025-10-16
-- Purpose: Add distance and amount tracking for delivery orders

USE delivery_db;

-- Add columns for pricing
ALTER TABLE orders
ADD COLUMN distance_km DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Khoảng cách theo km',
ADD COLUMN total_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Tổng tiền khách hàng phải trả',
ADD COLUMN shipper_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Số tiền shipper nhận (70%)',
ADD COLUMN app_commission DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Hoa hồng app (30%)';

-- Add indexes for better query performance
CREATE INDEX idx_distance ON orders(distance_km);
CREATE INDEX idx_total_amount ON orders(total_amount);
CREATE INDEX idx_status_shipper ON orders(status, shipper_id);

-- Update existing orders with default values (0.00)
-- Note: Existing orders will have 0.00 for all pricing fields
-- This is expected as they were created before pricing system

SELECT 'Migration completed successfully!' AS Status;
SELECT 'New columns added: distance_km, total_amount, shipper_amount, app_commission' AS Info;