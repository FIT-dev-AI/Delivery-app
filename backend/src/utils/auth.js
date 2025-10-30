const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Hash mật khẩu
const hashPassword = async (password) => {
  return await bcrypt.hash(password, 10);
};

// So sánh mật khẩu
const comparePassword = async (password, hash) => {
  return await bcrypt.compare(password, hash);
};

// Tạo JWT token
const generateToken = (userId, role) => {
  return jwt.sign(
    { id: userId, role: role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

// Xác thực JWT token
const verifyToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

module.exports = { hashPassword, comparePassword, generateToken, verifyToken };
