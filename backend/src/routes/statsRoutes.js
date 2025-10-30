const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/authMiddleware');
const { getDashboard } = require('../controllers/statsController');

router.use(authenticate);

router.get('/dashboard', getDashboard);

module.exports = router;
