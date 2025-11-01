-- Fix orders where shipper_id incorrectly points to admin user
-- This fixes the bug where admin reassign caused shipper_id to be set to admin user ID

USE delivery_db;

-- Step 1: Check for orders with admin as shipper
SELECT 
    o.id as order_id,
    o.status,
    o.shipper_id,
    u.name as shipper_name,
    u.role as shipper_role,
    u.id as user_id
FROM orders o
LEFT JOIN users u ON o.shipper_id = u.id
WHERE u.role = 'admin' AND o.shipper_id IS NOT NULL;

-- Step 2: Fix these orders by setting shipper_id to NULL (return to pending)
-- This allows proper reassignment
UPDATE orders o
INNER JOIN users u ON o.shipper_id = u.id
SET o.shipper_id = NULL, o.status = 'pending'
WHERE u.role = 'admin' AND o.shipper_id IS NOT NULL;

-- Step 3: Verify fix
SELECT 
    o.id as order_id,
    o.status,
    o.shipper_id,
    CASE 
        WHEN o.shipper_id IS NULL THEN 'NULL (Pending)'
        WHEN u.role = 'shipper' THEN CONCAT(u.name, ' (Shipper)')
        WHEN u.role = 'admin' THEN CONCAT(u.name, ' (ADMIN - FIXED)')
        ELSE 'Unknown'
    END as shipper_info
FROM orders o
LEFT JOIN users u ON o.shipper_id = u.id
WHERE o.shipper_id IS NOT NULL OR o.status = 'pending'
ORDER BY o.id DESC
LIMIT 20;

SELECT '✅ Orders with admin as shipper have been fixed!' AS Status;

