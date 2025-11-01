// backend/src/controllers/orderController.js
// ✅ FINAL: Weight validation + Inline pricing (NO external pricingService needed)

const orderModel = require('../models/orderModel');

// ✅ Valid categories list
const VALID_CATEGORIES = [
  'regular', 'food', 'frozen', 'valuable', 'electronics',
  'fashion', 'documents', 'fragile', 'medical', 'gift'
];

// ✅ Weight constraints
const WEIGHT_MIN = 0;
const WEIGHT_MAX = 30;

// ✅ Pricing constants (inline - no external service needed)
const BASE_FEE = 15000;           // Base fee: 15,000 VND
const PRICE_PER_KM = 10000;       // Per km: 10,000 VND
const COMMISSION_RATE = 0.20;     // App commission: 20%

/**
 * ✅ Calculate pricing inline (no external service)
 */
const calculatePricing = (distanceKm) => {
  const distanceFee = distanceKm * PRICE_PER_KM;
  const totalAmount = BASE_FEE + distanceFee;
  const appCommission = totalAmount * COMMISSION_RATE;
  const shipperAmount = totalAmount - appCommission;

  return {
    distanceKm: parseFloat(distanceKm.toFixed(2)),
    baseAmount: BASE_FEE,
    distanceFee: parseFloat(distanceFee.toFixed(0)),
    totalAmount: parseFloat(totalAmount.toFixed(0)),
    shipperAmount: parseFloat(shipperAmount.toFixed(0)),
    appCommission: parseFloat(appCommission.toFixed(0)),
  };
};

const orderController = {
  // ============ CREATE ORDER ============
  createOrder: async (req, res) => {
    try {
      const {
        customer_id,
        pickup_address, pickup_lat, pickup_lng,
        delivery_address, delivery_lat, delivery_lng,
        distance_km,
        category,
        weight,
        notes,
      } = req.body;

      // ============ VALIDATION ============
      
      // Validate required fields
      if (!customer_id || !pickup_address || !pickup_lat || !pickup_lng ||
          !delivery_address || !delivery_lat || !delivery_lng || !distance_km) {
        return res.status(400).json({
          success: false,
          message: 'Thiếu thông tin bắt buộc',
        });
      }

      // ✅ Validate weight is provided
      if (weight === undefined || weight === null) {
        return res.status(400).json({
          success: false,
          message: 'Vui lòng nhập cân nặng đơn hàng',
        });
      }

      // ✅ Validate weight is a valid number
      const weightNum = parseFloat(weight);
      if (isNaN(weightNum)) {
        return res.status(400).json({
          success: false,
          message: 'Cân nặng không hợp lệ',
        });
      }

      // ✅ Validate weight range (0-30kg)
      if (weightNum < WEIGHT_MIN || weightNum > WEIGHT_MAX) {
        return res.status(400).json({
          success: false,
          message: `Cân nặng phải từ ${WEIGHT_MIN}kg đến ${WEIGHT_MAX}kg (xe máy không thể chở quá ${WEIGHT_MAX}kg)`,
        });
      }

      // Validate category
      const validatedCategory = category && VALID_CATEGORIES.includes(category) 
        ? category 
        : 'regular';

      if (category && !VALID_CATEGORIES.includes(category)) {
        console.warn(`⚠️ Invalid category '${category}' provided, using 'regular'`);
      }

      // ============ CALCULATE PRICING (INLINE) ============
      const pricing = calculatePricing(distance_km);

      // ============ CREATE ORDER ============
      const orderId = await orderModel.createOrder({
        customer_id,
        pickup_address,
        pickup_lat,
        pickup_lng,
        delivery_address,
        delivery_lat,
        delivery_lng,
        category: validatedCategory,
        weight: weightNum,
        distance_km: pricing.distanceKm,
        total_amount: pricing.totalAmount,
        shipper_amount: pricing.shipperAmount,
        app_commission: pricing.appCommission,
        notes,
      });

      console.log(`✅ Order created: ID=${orderId}, Category=${validatedCategory}, Weight=${weightNum}kg, Distance=${distance_km}km, Price=${pricing.totalAmount}đ`);

      return res.status(201).json({
        success: true,
        message: 'Tạo đơn hàng thành công',
        data: {
          orderId,
          category: validatedCategory,
          weight: weightNum,
          pricing: {
            distance_km: pricing.distanceKm,
            base_amount: pricing.baseAmount,
            distance_fee: pricing.distanceFee,
            total_amount: pricing.totalAmount,
            shipper_amount: pricing.shipperAmount,
            app_commission: pricing.appCommission,
          },
        },
      });
    } catch (error) {
      console.error('❌ Error creating order:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi tạo đơn hàng',
        error: error.message,
      });
    }
  },

  // ============ GET ORDERS ============
  getOrders: async (req, res) => {
    try {
      const userId = req.user.id;
      const userRole = req.user.role;
      const { status } = req.query;

      let orders;

      if (userRole === 'customer') {
        orders = await orderModel.getOrdersByCustomer(userId, status);
      } else if (userRole === 'shipper') {
        orders = await orderModel.getOrdersByShipper(userId, status);
      } else if (userRole === 'admin') {
        orders = await orderModel.getAllOrders(status);
      } else {
        return res.status(403).json({
          success: false,
          message: 'Không có quyền truy cập',
        });
      }

      return res.status(200).json({
        success: true,
        data: { orders },
      });
    } catch (error) {
      console.error('❌ Error getting orders:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách đơn hàng',
        error: error.message,
      });
    }
  },

  getOrderById: async (req, res) => {
    try {
      const { id } = req.params;
      const order = await orderModel.getOrderById(id);

      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy đơn hàng',
        });
      }

      return res.status(200).json({
        success: true,
        data: { order },
      });
    } catch (error) {
      console.error('❌ Error getting order:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi lấy chi tiết đơn hàng',
        error: error.message,
      });
    }
  },

  // ============ GET ACTIVE ORDERS (SHIPPER) ============
  getActiveOrders: async (req, res) => {
    try {
      const shipperId = req.user.id;
      const orders = await orderModel.getActiveOrdersByShipper(shipperId);
      
      return res.status(200).json({
        success: true,
        data: { orders },
      });
    } catch (error) {
      console.error('❌ Error getting active orders:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi lấy đơn hàng đang thực hiện',
        error: error.message,
      });
    }
  },

  // ============ UPDATE OPERATIONS ============
  updateOrderStatus: async (req, res) => {
    try {
      const { id } = req.params;
      const { status, notes, photoUrl } = req.body;
      const userId = req.user.id;
      const userRole = req.user.role;

      // ✅ Validate status
      const validStatuses = ['pending', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: 'Trạng thái không hợp lệ',
        });
      }

      // ✅ Get order to check ownership
      const order = await orderModel.getOrderById(id);
      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy đơn hàng',
        });
      }

      // ✅ PERMISSION CHECK
      if (userRole === 'admin') {
        // Admin can update any status for any order
        console.log(`✅ Admin #${userId} updating order #${id} status to: ${status}`);
      } else if (userRole === 'shipper') {
        // Shipper can only update status for orders assigned to them
        if (order.shipper_id !== userId) {
          return res.status(403).json({
            success: false,
            message: 'Bạn không có quyền cập nhật đơn hàng này',
          });
        }

        // ✅ Shipper can only update to: picked_up, in_transit, delivered
        const allowedStatusesForShipper = ['picked_up', 'in_transit', 'delivered'];
        if (!allowedStatusesForShipper.includes(status)) {
          return res.status(403).json({
            success: false,
            message: `Tài xế chỉ có thể cập nhật trạng thái: ${allowedStatusesForShipper.join(', ')}`,
          });
        }

        // ✅ Validate status transition for shipper
        // Can only progress: assigned -> picked_up -> in_transit -> delivered
        const validTransitions = {
          'assigned': ['picked_up'],
          'picked_up': ['in_transit'],
          'in_transit': ['delivered'],
        };

        if (validTransitions[order.status] && !validTransitions[order.status].includes(status)) {
          return res.status(400).json({
            success: false,
            message: `Không thể chuyển từ "${order.status}" sang "${status}". Chuyển đổi hợp lệ: ${validTransitions[order.status].join(', ')}`,
          });
        }

        console.log(`✅ Shipper #${userId} updating order #${id} status: ${order.status} -> ${status}`);
      } else {
        // Customer cannot update order status
        return res.status(403).json({
          success: false,
          message: 'Bạn không có quyền cập nhật trạng thái đơn hàng',
        });
      }

      // ✅ Update status
      await orderModel.updateOrderStatus(id, status, notes);

      // ✅ If photoUrl is provided and status is picked_up or delivered, update proof image
      if (photoUrl && (status === 'picked_up' || status === 'delivered')) {
        await orderModel.updateProofImage(id, photoUrl);
      }

      return res.status(200).json({
        success: true,
        message: 'Cập nhật trạng thái thành công',
      });
    } catch (error) {
      console.error('❌ Error updating status:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi cập nhật trạng thái',
        error: error.message,
      });
    }
  },

  // ✅ NEW: Shipper self-assign (accept order)
  acceptOrder: async (req, res) => {
    try {
      const { id } = req.params;
      const shipperId = req.user.id;

      // ✅ Validate shipper role
      if (req.user.role !== 'shipper') {
        return res.status(403).json({
          success: false,
          message: 'Chỉ tài xế mới có thể nhận đơn hàng',
        });
      }

      // ✅ Validate shipper exists and is online
      const db = require('../config/database');
      const [shipperCheck] = await db.execute(
        'SELECT id, name, role, is_online FROM users WHERE id = ? AND role = "shipper"',
        [shipperId]
      );

      if (!shipperCheck || shipperCheck.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Tài xế không tồn tại',
        });
      }

      // ✅ Check if shipper is online
      if (shipperCheck[0].is_online !== 1 && shipperCheck[0].is_online !== true) {
        return res.status(400).json({
          success: false,
          message: 'Bạn đang OFFLINE. Vui lòng bật trạng thái Online để nhận đơn.',
        });
      }

      // ✅ Check if order exists and is pending
      const order = await orderModel.getOrderById(id);
      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy đơn hàng',
        });
      }

      if (order.status !== 'pending') {
        return res.status(400).json({
          success: false,
          message: 'Đơn hàng này đã được nhận bởi tài xế khác',
        });
      }

      // ✅ Check if shipper has active orders
      const activeOrders = await orderModel.getActiveOrdersByShipper(shipperId);
      if (activeOrders && activeOrders.length > 0) {
        const activeOrder = activeOrders[0];
        return res.status(400).json({
          success: false,
          message: `Bạn đang có đơn hàng #${activeOrder.id} chưa hoàn thành. Vui lòng hoàn thành đơn hiện tại trước khi nhận đơn mới.`,
        });
      }

      // ✅ Assign order to shipper
      const success = await orderModel.assignShipper(id, shipperId);

      if (!success) {
        return res.status(400).json({
          success: false,
          message: 'Không thể nhận đơn (đơn đã được nhận hoặc không tồn tại)',
        });
      }

      console.log(`✅ Order #${id} accepted by shipper #${shipperId} (${shipperCheck[0].name})`);
      
      return res.status(200).json({
        success: true,
        message: 'Nhận đơn hàng thành công',
      });
    } catch (error) {
      console.error('❌ Error accepting order:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi nhận đơn hàng',
        error: error.message,
      });
    }
  },

  // ✅ UPDATED: Admin reassign (only for admin, requires shipper_id in body)
  assignShipper: async (req, res) => {
    try {
      const { id } = req.params;
      
      // ✅ FIXED: Admin reassign MUST provide shipper_id in body
      if (!req.body.shipper_id) {
        return res.status(400).json({
          success: false,
          message: 'Vui lòng cung cấp shipper_id để phân công đơn hàng',
        });
      }

      const shipperId = req.body.shipper_id;

      // ✅ FIXED: Validate that the shipper exists and is actually a shipper
      const db = require('../config/database');
      const [shipperCheck] = await db.execute(
        'SELECT id, name, role, is_online FROM users WHERE id = ? AND role = "shipper"',
        [shipperId]
      );

      if (!shipperCheck || shipperCheck.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Shipper không tồn tại hoặc không phải là tài xế',
        });
      }

      // ✅ FIXED: Check if shipper is online when admin reassigns
      if (shipperCheck[0].is_online !== 1 && shipperCheck[0].is_online !== true) {
        return res.status(400).json({
          success: false,
          message: 'Tài xế đang OFFLINE. Vui lòng bật trạng thái Online để nhận đơn.',
        });
      }

      // ✅ Check if order exists
      const order = await orderModel.getOrderById(id);
      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy đơn hàng',
        });
      }

      const success = await orderModel.assignShipper(id, shipperId);

      if (!success) {
        return res.status(400).json({
          success: false,
          message: 'Không thể phân công đơn hàng',
        });
      }

      console.log(`✅ Order #${id} reassigned to shipper #${shipperId} (${shipperCheck[0].name}) by admin #${req.user.id}`);
      
      return res.status(200).json({
        success: true,
        message: `Đã phân công đơn hàng cho ${shipperCheck[0].name}`,
      });
    } catch (error) {
      console.error('❌ Error assigning shipper:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi phân công đơn hàng',
        error: error.message,
      });
    }
  },

  uploadProof: async (req, res) => {
    try {
      const { id } = req.params;
      const { proof_image_base64 } = req.body;
      const userId = req.user.id;
      const userRole = req.user.role;

      if (!proof_image_base64) {
        return res.status(400).json({
          success: false,
          message: 'Thiếu ảnh xác nhận',
        });
      }

      // ✅ Get order to check ownership (for shipper)
      const order = await orderModel.getOrderById(id);
      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy đơn hàng',
        });
      }

      // ✅ PERMISSION CHECK
      if (userRole === 'admin') {
        // Admin can upload proof for any order
        console.log(`✅ Admin #${userId} uploading proof for order #${id}`);
      } else if (userRole === 'shipper') {
        // Shipper can only upload proof for orders assigned to them
        if (order.shipper_id !== userId) {
          return res.status(403).json({
            success: false,
            message: 'Bạn không có quyền upload ảnh xác nhận cho đơn hàng này',
          });
        }

        // ✅ Shipper can only upload proof for delivered orders (or when delivering)
        if (order.status !== 'delivered' && order.status !== 'in_transit') {
          return res.status(400).json({
            success: false,
            message: 'Chỉ có thể upload ảnh xác nhận khi đang giao hàng hoặc đã giao hàng',
          });
        }

        console.log(`✅ Shipper #${userId} uploading proof for order #${id}`);
      } else {
        return res.status(403).json({
          success: false,
          message: 'Bạn không có quyền upload ảnh xác nhận',
        });
      }

      await orderModel.updateProofImage(id, proof_image_base64);

      return res.status(200).json({
        success: true,
        message: 'Upload ảnh xác nhận thành công',
      });
    } catch (error) {
      console.error('❌ Error uploading proof:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi upload ảnh',
        error: error.message,
      });
    }
  },

  cancelOrder: async (req, res) => {
    try {
      const { id } = req.params;
      const shipperId = req.user.id;
      const { cancel_reason } = req.body;

      if (!cancel_reason || cancel_reason.trim() === '') {
        return res.status(400).json({
          success: false,
          message: 'Vui lòng nhập lý do hủy đơn',
        });
      }

      await orderModel.cancelOrderByShipper(id, shipperId, cancel_reason);

      return res.status(200).json({
        success: true,
        message: 'Hủy đơn hàng thành công',
      });
    } catch (error) {
      console.error('❌ Error cancelling order:', error);
      return res.status(500).json({
        success: false,
        message: error.message || 'Lỗi hủy đơn hàng',
        error: error.message,
      });
    }
  },
};

module.exports = orderController;