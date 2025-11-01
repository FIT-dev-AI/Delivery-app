// backend/src/models/userModel.js
// ✅ UPDATED: Enhanced logging and verification for online status + Admin functions

const db = require('../config/database');
const bcrypt = require('bcrypt');

/**
 * Create new user
 */
const createUser = async (userData) => {
  try {
    const { name, email, password, role = 'customer', phone = null } = userData;

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const query = `
      INSERT INTO users (name, email, password, role, phone)
      VALUES (?, ?, ?, ?, ?)
    `;

    const [result] = await db.execute(query, [
      name,
      email,
      hashedPassword,
      role,
      phone,
    ]);

    return result.insertId;
  } catch (error) {
    console.error('Error creating user:', error);
    throw error;
  }
};

/**
 * Get user by ID
 */
const getUserById = async (userId) => {
  try {
    const query = `
      SELECT id, name, email, role, phone, is_online, created_at
      FROM users
      WHERE id = ?
    `;

    const [users] = await db.execute(query, [userId]);
    return users[0] || null;
  } catch (error) {
    console.error('Error getting user by ID:', error);
    throw error;
  }
};

/**
 * Get user by email (with password for authentication)
 */
const getUserByEmail = async (email) => {
  try {
    const query = `
      SELECT id, name, email, password, role, phone, is_online, created_at
      FROM users
      WHERE email = ?
    `;

    const [users] = await db.execute(query, [email]);
    return users[0] || null;
  } catch (error) {
    console.error('Error getting user by email:', error);
    throw error;
  }
};

/**
 * Get user by email (without password for general use)
 */
const getUserByEmailPublic = async (email) => {
  try {
    const query = `
      SELECT id, name, email, role, phone, is_online, created_at
      FROM users
      WHERE email = ?
    `;

    const [users] = await db.execute(query, [email]);
    return users[0] || null;
  } catch (error) {
    console.error('Error getting user by email:', error);
    throw error;
  }
};

/**
 * Update user profile
 */
const updateUser = async (userId, updates) => {
  try {
    const { name, phone } = updates;
    
    const query = `
      UPDATE users
      SET name = ?, phone = ?
      WHERE id = ?
    `;

    const [result] = await db.execute(query, [name, phone, userId]);
    return result.affectedRows > 0;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
};

/**
 * Update user password
 */
const updatePassword = async (userId, newPassword) => {
  try {
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    const query = `
      UPDATE users
      SET password = ?
      WHERE id = ?
    `;

    const [result] = await db.execute(query, [hashedPassword, userId]);
    return result.affectedRows > 0;
  } catch (error) {
    console.error('Error updating password:', error);
    throw error;
  }
};

/**
 * Verify password
 */
const verifyPassword = async (plainPassword, hashedPassword) => {
  try {
    return await bcrypt.compare(plainPassword, hashedPassword);
  } catch (error) {
    console.error('Error verifying password:', error);
    throw error;
  }
};

/**
 * Delete user (soft delete by setting is_active = 0)
 */
const deleteUser = async (userId) => {
  try {
    const query = `
      UPDATE users
      SET is_active = 0
      WHERE id = ?
    `;

    const [result] = await db.execute(query, [userId]);
    return result.affectedRows > 0;
  } catch (error) {
    console.error('Error deleting user:', error);
    throw error;
  }
};

/**
 * Get all users (admin only)
 */
const getAllUsers = async (filters = {}) => {
  try {
    let query = `
      SELECT id, name, email, role, phone, is_online, created_at
      FROM users
      WHERE 1=1
    `;
    
    const params = [];

    if (filters.role) {
      query += ' AND role = ?';
      params.push(filters.role);
    }

    if (filters.search) {
      query += ' AND (name LIKE ? OR email LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm);
    }

    query += ' ORDER BY created_at DESC';

    const [users] = await db.execute(query, params);
    return users;
  } catch (error) {
    console.error('Error getting all users:', error);
    throw error;
  }
};

/**
 * Get user statistics
 */
const getUserStats = async (userId, role) => {
  try {
    if (role === 'customer') {
      const query = `
        SELECT 
          COUNT(*) as total_orders,
          SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) as completed_orders,
          SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_orders,
          SUM(CASE WHEN status IN ('pending', 'assigned', 'picked_up', 'in_transit') THEN 1 ELSE 0 END) as active_orders
        FROM orders
        WHERE customer_id = ?
      `;
      
      const [stats] = await db.execute(query, [userId]);
      return stats[0];
    } else if (role === 'shipper') {
      const query = `
        SELECT 
          COUNT(*) as total_deliveries,
          SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) as completed_deliveries,
          SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_deliveries,
          SUM(CASE WHEN status IN ('assigned', 'picked_up', 'in_transit') THEN 1 ELSE 0 END) as active_deliveries
        FROM orders
        WHERE shipper_id = ?
      `;
      
      const [stats] = await db.execute(query, [userId]);
      return stats[0];
    }
    
    return null;
  } catch (error) {
    console.error('Error getting user stats:', error);
    throw error;
  }
};

/**
 * ✅ UPDATED: Update online status with enhanced logging and verification
 */
const updateOnlineStatus = async (userId, isOnline) => {
  try {
    const onlineValue = isOnline ? 1 : 0;
    const statusText = isOnline ? '🟢 ONLINE' : '🔴 OFFLINE';
    
    // Step 1: Check current status BEFORE update
    const [beforeUpdate] = await db.execute(
      'SELECT id, name, role, is_online FROM users WHERE id = ?',
      [userId]
    );
    
    if (beforeUpdate.length === 0) {
      console.error(`❌ User #${userId} not found`);
      throw new Error('User not found');
    }
    
    const user = beforeUpdate[0];
    const beforeStatus = user.is_online === 1 ? '🟢 ONLINE' : '🔴 OFFLINE';
    console.log(`📍 BEFORE Update: User #${userId} (${user.name}) was ${beforeStatus}`);
    
    // Step 2: Perform UPDATE
    const query = `
      UPDATE users 
      SET is_online = ?, last_online = NOW()
      WHERE id = ?
    `;
    
    const [result] = await db.execute(query, [onlineValue, userId]);
    
    console.log(`✅ UPDATE executed: affected ${result.affectedRows} row(s)`);
    
    // Step 3: Verify the update with fresh SELECT
    const [afterUpdate] = await db.execute(
      'SELECT id, name, role, is_online, last_online FROM users WHERE id = ?',
      [userId]
    );
    
    if (afterUpdate.length === 0) {
      console.error(`❌ Verification failed: User #${userId} not found after update`);
      throw new Error('Update verification failed');
    }
    
    const updatedUser = afterUpdate[0];
    const afterStatus = updatedUser.is_online === 1 ? '🟢 ONLINE' : '🔴 OFFLINE';
    
    console.log(`🔍 AFTER Update: User #${userId} (${updatedUser.name}) is now ${afterStatus}`);
    console.log(`   📅 Last online: ${updatedUser.last_online}`);
    
    // Step 4: Verify the value matches what we tried to set
    if (updatedUser.is_online !== onlineValue) {
      console.error(`⚠️ WARNING: Expected is_online=${onlineValue}, but got ${updatedUser.is_online}`);
      throw new Error('Online status mismatch after update');
    }
    
    console.log(`✅ VERIFIED: Online status successfully updated to ${statusText}`);
    
    return true;
  } catch (error) {
    console.error('❌ Error updating online status:', error);
    throw error;
  }
};

/**
 * ✅ NEW: Update user status (active/inactive) - Admin only
 */
const updateUserStatus = async (userId, isActive) => {
  try {
    const activeValue = isActive ? 1 : 0;
    
    const query = `
      UPDATE users
      SET is_active = ?
      WHERE id = ?
    `;

    const [result] = await db.execute(query, [activeValue, userId]);
    
    if (result.affectedRows === 0) {
      throw new Error('User not found or no changes made');
    }
    
    console.log(`✅ User #${userId} status updated to ${isActive ? 'ACTIVE' : 'INACTIVE'}`);
    return true;
  } catch (error) {
    console.error('Error updating user status:', error);
    throw error;
  }
};

/**
 * ✅ NEW: Get online shippers - Admin only
 */
const getOnlineShippers = async () => {
  try {
    const query = `
      SELECT 
        id, 
        name, 
        email, 
        phone, 
        is_online,
        last_online,
        created_at
      FROM users
      WHERE role = 'shipper' 
        AND is_online = 1
        AND is_active = 1
      ORDER BY last_online DESC
    `;

    const [shippers] = await db.execute(query);
    
    console.log(`📊 Found ${shippers.length} online shipper(s)`);
    return shippers;
  } catch (error) {
    console.error('Error getting online shippers:', error);
    throw error;
  }
};

module.exports = {
  createUser,
  getUserById,
  getUserByEmail,
  getUserByEmailPublic,
  updateUser,
  updatePassword,
  verifyPassword,
  deleteUser,
  getAllUsers,
  getUserStats,
  updateOnlineStatus,
  updateUserStatus,
  getOnlineShippers,
};