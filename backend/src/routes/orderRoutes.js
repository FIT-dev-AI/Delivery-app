const express = require('express');
const router = express.Router();
// Dùng destructuring { } để lấy đúng hàm 'authenticate' và 'isAdmin' từ object được export
const { authenticate, isAdmin } = require('../middleware/authMiddleware');
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

// ✅ UPDATED: Allow shipper to update status for their orders, admin can update any order
router.put('/:id/status', updateOrderStatusValidation, orderController.updateOrderStatus);

// ✅ NEW: Shipper can accept order (self-assign)
router.put('/:id/accept', idParamValidation, orderController.acceptOrder);

// ✅ SECURED: Only admin can reassign shipper (requires shipper_id in body)
router.put('/:id/assign', isAdmin, idParamValidation, orderController.assignShipper);

router.put('/:id/proof', idParamValidation, orderController.uploadProof);

module.exports = router;