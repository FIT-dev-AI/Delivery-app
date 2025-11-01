const { verifyToken } = require('../utils/auth');
const { ApiError } = require('./errorHandler');
const userModel = require('../models/userModel');

/**
 * Authenticate user via JWT token
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new ApiError(401, 'Vui lòng đăng nhập để tiếp tục');
    }

    const token = authHeader.substring(7);

    // Verify token
    let decoded;
    try {
      decoded = verifyToken(token);
    } catch (error) {
      throw new ApiError(401, error.message);
    }

    // Get user from database
    const user = await userModel.getUserById(decoded.id);
    
    if (!user) {
      throw new ApiError(401, 'Người dùng không tồn tại');
    }

    // Attach user to request
    req.user = {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      phone: user.phone,
    };

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Authorize based on roles
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new ApiError(401, 'Vui lòng đăng nhập'));
    }

    if (!roles.includes(req.user.role)) {
      return next(
        new ApiError(403, 'Bạn không có quyền truy cập chức năng này')
      );
    }

    next();
  };
};

/**
 * Check if user is admin
 */
const isAdmin = (req, res, next) => {
  if (!req.user) {
    return next(new ApiError(401, 'Vui lòng đăng nhập'));
  }

  if (req.user.role !== 'admin') {
    return next(new ApiError(403, 'Chỉ Admin mới có quyền truy cập'));
  }

  next();
};

module.exports = {
  authenticate,
  authorize,
  isAdmin,
};