const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

/**
 * Hash password using bcrypt
 * @param {string} password - Plain text password
 * @returns {Promise<string>} - Hashed password
 */
const hashPassword = async (password) => {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
};

/**
 * Compare password with hash
 * @param {string} password - Plain text password
 * @param {string} hash - Hashed password
 * @returns {Promise<boolean>} - True if match
 */
const comparePassword = async (password, hash) => {
  return await bcrypt.compare(password, hash);
};

/**
 * Generate JWT token
 * @param {number} userId - User ID
 * @param {string} role - User role
 * @returns {string} - JWT token
 */
const generateToken = (userId, role) => {
  return jwt.sign(
    { 
      id: userId, 
      role: role,
      iat: Math.floor(Date.now() / 1000), // Issued at
    },
    process.env.JWT_SECRET,
    { 
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
      issuer: 'delivery-app',
    }
  );
};

/**
 * Verify JWT token
 * @param {string} token - JWT token
 * @returns {object} - Decoded token payload
 */
const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new Error('Token đã hết hạn');
    }
    if (error.name === 'JsonWebTokenError') {
      throw new Error('Token không hợp lệ');
    }
    throw error;
  }
};

/**
 * Generate refresh token (longer expiry)
 * @param {number} userId - User ID
 * @returns {string} - Refresh token
 */
const generateRefreshToken = (userId) => {
  return jwt.sign(
    { id: userId, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
};

module.exports = { 
  hashPassword, 
  comparePassword, 
  generateToken, 
  verifyToken,
  generateRefreshToken,
};