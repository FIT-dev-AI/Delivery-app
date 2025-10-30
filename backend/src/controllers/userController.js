const userModel = require('../models/userModel');
const asyncHandler = require('../utils/asyncHandler');
const { ApiError } = require('../middleware/errorHandler');

const getProfile = asyncHandler(async (req, res) => {
  const user = await userModel.getUserById(req.user.id);
  if (!user) {
    throw new ApiError(404, 'Không tìm thấy người dùng');
  }
  
  res.json({
    success: true,
    message: 'Lấy thông tin profile thành công',
    data: { user },
  });
});

const updateProfile = asyncHandler(async (req, res) => {
  const { name, phone } = req.body;
  
  if (!name || name.trim().length < 2) {
    throw new ApiError(400, 'Tên phải có ít nhất 2 ký tự');
  }
  
  if (phone && !/^[0-9]{10,11}$/.test(phone)) {
    throw new ApiError(400, 'Số điện thoại không hợp lệ');
  }
  
  await userModel.updateUser(req.user.id, { name: name.trim(), phone: phone || null });
  const updatedUser = await userModel.getUserById(req.user.id);
  
  res.json({
    success: true,
    message: 'Cập nhật profile thành công',
    data: { user: updatedUser },
  });
});

const changePassword = asyncHandler(async (req, res) => {
  const { currentPassword, newPassword, confirmPassword } = req.body;
  
  if (!currentPassword || !newPassword || !confirmPassword) {
    throw new ApiError(400, 'Vui lòng điền đầy đủ thông tin');
  }
  
  if (newPassword !== confirmPassword) {
    throw new ApiError(400, 'Mật khẩu mới không khớp');
  }
  
  if (newPassword.length < 6) {
    throw new ApiError(400, 'Mật khẩu mới phải có ít nhất 6 ký tự');
  }
  
  const user = await userModel.getUserById(req.user.id);
  if (!user) {
    throw new ApiError(404, 'Không tìm thấy người dùng');
  }
  
  if (!(await userModel.verifyPassword(currentPassword, user.password))) {
    throw new ApiError(401, 'Mật khẩu hiện tại không đúng');
  }
  
  await userModel.updatePassword(req.user.id, newPassword);
  
  res.json({
    success: true,
    message: 'Đổi mật khẩu thành công',
  });
});

const getSettings = asyncHandler(async (req, res) => {
  const settings = await userModel.getUserSettings(req.user.id);
  
  res.json({
    success: true,
    message: 'Lấy settings thành công',
    data: { settings },
  });
});

const updateSettings = asyncHandler(async (req, res) => {
  const { notifications, language, theme } = req.body;
  
  if (language && !['vi', 'en'].includes(language)) {
    throw new ApiError(400, 'Ngôn ngữ không hợp lệ');
  }
  
  if (theme && !['light', 'dark'].includes(theme)) {
    throw new ApiError(400, 'Theme không hợp lệ');
  }
  
  const updatedSettings = await userModel.updateUserSettings(req.user.id, {
    notifications,
    language,
    theme,
  });
  
  res.json({
    success: true,
    message: 'Cập nhật settings thành công',
    data: { settings: updatedSettings },
  });
});

module.exports = {
  getProfile,
  updateProfile,
  changePassword,
  getSettings,
  updateSettings,
};
