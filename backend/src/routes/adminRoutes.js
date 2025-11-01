const express = require('express');
const router = express.Router();
const { authenticate, isAdmin } = require('../middleware/authMiddleware');
const adminController = require('../controllers/adminController');

// All admin routes require authentication and admin role
router.use(authenticate);
router.use(isAdmin);

// User Management
router.get('/users', adminController.handleGetAllUsers);
router.put('/users/:id/status', adminController.handleUpdateUserStatus);

// Shipper Management
router.get('/shippers/online', adminController.handleGetOnlineShippers);

module.exports = router;