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
      const { status, notes } = req.body;

      const validStatuses = ['pending', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: 'Trạng thái không hợp lệ',
        });
      }

      await orderModel.updateOrderStatus(id, status, notes);

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

  assignShipper: async (req, res) => {
    try {
      const { id } = req.params;
      const shipperId = req.user.id;

      const success = await orderModel.assignShipper(id, shipperId);

      if (!success) {
        return res.status(400).json({
          success: false,
          message: 'Không thể nhận đơn (đơn đã được nhận hoặc không tồn tại)',
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Nhận đơn hàng thành công',
      });
    } catch (error) {
      console.error('❌ Error assigning shipper:', error);
      return res.status(500).json({
        success: false,
        message: 'Lỗi nhận đơn hàng',
        error: error.message,
      });
    }
  },

  uploadProof: async (req, res) => {
    try {
      const { id } = req.params;
      const { proof_image_base64 } = req.body;

      if (!proof_image_base64) {
        return res.status(400).json({
          success: false,
          message: 'Thiếu ảnh xác nhận',
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