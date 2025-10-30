const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate } = require('../middleware/authMiddleware');
const { changePasswordValidation } = require('../middleware/validators'); // <-- IMPORT

// Tất cả routes cần authentication
router.use(authenticate);

// Profile routes
router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);

// Password route
// Áp dụng validation cho việc đổi mật khẩu
router.put('/password', changePasswordValidation, userController.changePassword); // <-- SỬ DỤNG

// Settings routes
router.get('/settings', userController.getSettings);
router.put('/settings', userController.updateSettings);

module.exports = router;
