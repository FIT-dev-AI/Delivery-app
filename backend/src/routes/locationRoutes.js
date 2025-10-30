const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/authMiddleware');
const { idParamValidation } = require('../middleware/validators'); // <-- IMPORT
const {
  updateLocation,
  getShipperLocation,
  getLocationHistory,
} = require('../controllers/locationController');

router.use(authenticate);

router.post('/update', updateLocation);

// Thêm validation cho shipperId
router.get('/shipper/:shipperId', idParamValidation, getShipperLocation); // <-- SỬ DỤNG

// Thêm validation cho orderId
router.get('/order/:orderId/history', idParamValidation, getLocationHistory); // <-- SỬ DỤNG

module.exports = router;
