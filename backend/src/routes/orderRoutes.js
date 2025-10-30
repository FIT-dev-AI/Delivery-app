const express = require('express');
const router = express.Router();
// Dùng destructuring { } để lấy đúng hàm 'authenticate' từ object được export
const { authenticate } = require('../middleware/authMiddleware');
const {
  createOrderValidation,
  updateOrderStatusValidation,
  idParamValidation,
} = require('../middleware/validators');
const orderController = require('../controllers/orderController');

// Giờ đây 'authenticate' là một hàm hợp lệ
router.use(authenticate);

router
  .route('/')
  .post(createOrderValidation, orderController.createOrder)
  .get(orderController.getOrders);

// ✅ Active orders must be before /:id
router.get('/active', orderController.getActiveOrders);

// ✅ NEW: Cancel order route (MUST be before /:id)
router.put('/:id/cancel', idParamValidation, orderController.cancelOrder);

router.route('/:id').get(idParamValidation, orderController.getOrderById);

router.put('/:id/status', updateOrderStatusValidation, orderController.updateOrderStatus);
router.put('/:id/assign', idParamValidation, orderController.assignShipper);
router.put('/:id/proof', idParamValidation, orderController.uploadProof);

module.exports = router;
