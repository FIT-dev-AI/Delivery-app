// backend/routes/authRoutes.js
// ✅ UPDATED: Add forgot password routes

const express = require('express');
const router = express.Router();
const {
  login,
  register,
  updateOnlineStatus,
  forgotPassword,    // ✅ NEW
  verifyOTP,         // ✅ NEW
  resetPassword,     // ✅ NEW
} = require('../controllers/authController');
const { authenticate } = require('../middleware/authMiddleware');

// Public routes (no authentication)
router.post('/login', login);
router.post('/register', register);

// ✅ NEW: Forgot password routes (public)
router.post('/forgot-password', forgotPassword);
router.post('/verify-otp', verifyOTP);
router.post('/reset-password', resetPassword);

// Protected routes (require authentication)
router.patch('/online-status', authenticate, updateOnlineStatus);

module.exports = router;
