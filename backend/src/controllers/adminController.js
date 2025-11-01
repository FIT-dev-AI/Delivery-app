const userModel = require('../models/userModel');
const { ApiError } = require('../middleware/errorHandler');

/**
 * Get all users (Admin only)
 */
const handleGetAllUsers = async (req, res, next) => {
  try {
    const { role, search } = req.query;
    
    const filters = {};
    if (role) filters.role = role;
    if (search) filters.search = search;

    const users = await userModel.getAllUsers(filters);

    res.json({
      success: true,
      data: users,
      message: `Lấy danh sách ${users.length} user thành công`,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update user status (active/inactive) - Admin only
 */
const handleUpdateUserStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    if (typeof isActive !== 'boolean') {
      throw new ApiError(400, 'isActive phải là boolean (true/false)');
    }

    // Check if user exists
    const user = await userModel.getUserById(id);
    if (!user) {
      throw new ApiError(404, 'User không tồn tại');
    }

    // Prevent admin from deactivating themselves
    if (parseInt(id) === req.user.id && !isActive) {
      throw new ApiError(400, 'Bạn không thể vô hiệu hóa tài khoản của chính mình');
    }

    await userModel.updateUserStatus(id, isActive);

    res.json({
      success: true,
      message: `Cập nhật trạng thái user #${id} thành công`,
      data: {
        userId: id,
        isActive,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get online shippers - Admin only
 */
const handleGetOnlineShippers = async (req, res, next) => {
  try {
    const shippers = await userModel.getOnlineShippers();

    res.json({
      success: true,
      data: shippers,
      message: `Có ${shippers.length} shipper đang online`,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  handleGetAllUsers,
  handleUpdateUserStatus,
  handleGetOnlineShippers,
};