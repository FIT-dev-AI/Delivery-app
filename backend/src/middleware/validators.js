const { body, param, query, validationResult } = require('express-validator');
const { ApiError } = require('./errorHandler');

/**
 * Validate request and throw error if validation fails
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map((err) => err.msg);
    throw new ApiError(400, errorMessages.join(', '));
  }
  
  next();
};

/**
 * User Registration Validation
 */
const registerValidation = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Tên không được để trống')
    .isLength({ min: 2, max: 100 })
    .withMessage('Tên phải từ 2-100 ký tự'),
  
  body('email')
    .trim()
    .notEmpty()
    .withMessage('Email không được để trống')
    .isEmail()
    .withMessage('Email không hợp lệ')
    .normalizeEmail(),
  
  body('password')
    .notEmpty()
    .withMessage('Mật khẩu không được để trống')
    .isLength({ min: 6 })
    .withMessage('Mật khẩu phải có ít nhất 6 ký tự'),
  
  body('role')
    .optional()
    .isIn(['customer', 'shipper', 'admin'])
    .withMessage('Role không hợp lệ'),
  
  body('phone')
    .optional()
    .matches(/^[0-9]{10,11}$/)
    .withMessage('Số điện thoại không hợp lệ'),
  
  validate,
];

/**
 * User Login Validation
 */
const loginValidation = [
  body('email')
    .trim()
    .notEmpty()
    .withMessage('Email không được để trống')
    .isEmail()
    .withMessage('Email không hợp lệ')
    .normalizeEmail(),
  
  body('password')
    .notEmpty()
    .withMessage('Mật khẩu không được để trống'),
  
  validate,
];

/**
 * Create Order Validation
 */
const createOrderValidation = [
  body('pickup_address')
    .trim()
    .notEmpty()
    .withMessage('Địa chỉ lấy hàng không được để trống'),
  
  body('pickup_lat')
    .notEmpty()
    .withMessage('Vĩ độ điểm lấy hàng không được trống')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Vĩ độ không hợp lệ'),
  
  body('pickup_lng')
    .notEmpty()
    .withMessage('Kinh độ điểm lấy hàng không được trống')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Kinh độ không hợp lệ'),
  
  body('delivery_address')
    .trim()
    .notEmpty()
    .withMessage('Địa chỉ giao hàng không được để trống'),
  
  body('delivery_lat')
    .notEmpty()
    .withMessage('Vĩ độ điểm giao hàng không được trống')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Vĩ độ không hợp lệ'),
  
  body('delivery_lng')
    .notEmpty()
    .withMessage('Kinh độ điểm giao hàng không được trống')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Kinh độ không hợp lệ'),
  
  body('notes')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Ghi chú không được vượt quá 500 ký tự'),
  
  validate,
];

/**
 * Update Order Status Validation
 */
const updateOrderStatusValidation = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('ID đơn hàng không hợp lệ'),
  
  body('status')
    .notEmpty()
    .withMessage('Trạng thái không được để trống')
    .isIn(['pending', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled'])
    .withMessage('Trạng thái không hợp lệ'),
  
  body('notes')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Ghi chú không được vượt quá 500 ký tự'),
  
  validate,
];

/**
 * ID Parameter Validation
 */
const idParamValidation = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('ID không hợp lệ'),
  
  validate,
];

/**
 * Change Password Validation
 */
const changePasswordValidation = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Mật khẩu hiện tại không được để trống'),
  
  body('newPassword')
    .notEmpty()
    .withMessage('Mật khẩu mới không được để trống')
    .isLength({ min: 6 })
    .withMessage('Mật khẩu mới phải có ít nhất 6 ký tự'),
  
  body('confirmPassword')
    .notEmpty()
    .withMessage('Xác nhận mật khẩu không được để trống')
    .custom((value, { req }) => value === req.body.newPassword)
    .withMessage('Mật khẩu xác nhận không khớp'),
  
  validate,
];

/**
 * Update Profile Validation
 */
const updateProfileValidation = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Tên không được để trống')
    .isLength({ min: 2, max: 100 })
    .withMessage('Tên phải từ 2-100 ký tự'),
  
  body('phone')
    .optional()
    .matches(/^[0-9]{10,11}$/)
    .withMessage('Số điện thoại không hợp lệ'),
  
  validate,
];

/**
 * Update Settings Validation
 */
const updateSettingsValidation = [
  body('language')
    .optional()
    .isIn(['vi', 'en'])
    .withMessage('Ngôn ngữ không hợp lệ'),
  
  body('theme')
    .optional()
    .isIn(['light', 'dark'])
    .withMessage('Theme không hợp lệ'),
  
  body('notifications')
    .optional()
    .isObject()
    .withMessage('Cài đặt thông báo không hợp lệ'),
  
  validate,
];

/**
 * Update Location Validation
 */
const updateLocationValidation = [
  body('latitude')
    .notEmpty()
    .withMessage('Vĩ độ không được để trống')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Vĩ độ không hợp lệ'),
  
  body('longitude')
    .notEmpty()
    .withMessage('Kinh độ không được để trống')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Kinh độ không hợp lệ'),
  
  body('accuracy')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Độ chính xác không hợp lệ'),
  
  validate,
];

module.exports = {
  validate,
  registerValidation,
  loginValidation,
  createOrderValidation,
  updateOrderStatusValidation,
  idParamValidation,
  changePasswordValidation,
  updateProfileValidation,
  updateSettingsValidation,
  updateLocationValidation,
};