const userModel = require('../models/userModel');
const { generateToken } = require('../utils/auth');
const { ApiError } = require('../middleware/errorHandler');
const asyncHandler = require('../utils/asyncHandler');
const db = require('../config/database');
const bcrypt = require('bcrypt');
const emailService = require('../../services/emailService');
const otpService = require('../../services/otpService');

const register = asyncHandler(async (req, res) => {
  const { email } = req.body;

  const existingUser = await userModel.getUserByEmail(email);
  if (existingUser) {
    throw new ApiError(409, 'Email đã được sử dụng');
  }

  // Tạo người dùng mới và lấy ID
  const userId = await userModel.createUser(req.body);
  const newUser = await userModel.getUserById(userId);

  // ====> THÊM PHẦN TẠO TOKEN <====
  // Sau khi tạo user thành công, tạo token ngay lập tức
  const token = generateToken(newUser.id, newUser.role);

  // Trả về response ĐẦY ĐỦ, giống hệt hàm login
  res.status(201).json({
    success: true,
    message: 'Đăng ký thành công',
    data: {
      token,
      user: newUser,
    },
  });
});

const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await userModel.getUserByEmail(email);
  if (!user || !(await userModel.verifyPassword(password, user.password))) {
    throw new ApiError(401, 'Email hoặc mật khẩu không đúng');
  }

  const token = generateToken(user.id, user.role);

  // Tạo đối tượng response để log ra
  const responseData = {
    success: true,
    message: 'Đăng nhập thành công',
    data: {
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
      },
    },
  };

  // ====> THÊM DÒNG NÀY ĐỂ KIỂM TRA <====
  console.log('✅ BACKEND RESPONSE:', JSON.stringify(responseData, null, 2));

  res.json(responseData);
});

// ✅ NEW: Update online status
const updateOnlineStatus = asyncHandler(async (req, res) => {
  const { is_online } = req.body;
  if (typeof is_online === 'undefined') {
    throw new ApiError(400, 'Thiếu trường is_online');
  }
  await userModel.updateOnlineStatus(req.user.id, Boolean(is_online));
  res.json({ success: true, message: 'Cập nhật trạng thái online thành công' });
});

module.exports = { register, login, updateOnlineStatus };
// ============================================
// FORGOT PASSWORD FLOW
// ============================================

/**
 * Step 1: Request OTP
 * POST /api/auth/forgot-password
 * Body: { email }
 */
const forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;

  // Validate email
  if (!email || !email.trim()) {
    throw new ApiError(400, 'Vui lòng nhập địa chỉ email');
  }

  // Check if user exists
  const [users] = await db.execute(
    'SELECT id, name, email, role FROM users WHERE email = ?',
    [email.trim().toLowerCase()]
  );

  if (users.length === 0) {
    throw new ApiError(404, 'Không tìm thấy tài khoản với email này');
  }

  const user = users[0];

  // Generate OTP
  const otp = otpService.generateOTP();
  const otpExpiry = otpService.getOTPExpiry();

  // Save OTP to database
  await db.execute(
    `UPDATE users 
     SET reset_otp = ?, 
         reset_otp_expiry = ?, 
         reset_otp_attempts = 0,
         updated_at = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [otp, otpExpiry, user.id]
  );

  // Send OTP via email
  try {
    await emailService.sendOTP(email, otp, user.name);
  } catch (error) {
    // Rollback OTP if email fails
    await db.execute(
      'UPDATE users SET reset_otp = NULL, reset_otp_expiry = NULL WHERE id = ?',
      [user.id]
    );
    throw new ApiError(500, 'Không thể gửi email. Vui lòng thử lại sau.');
  }

  console.log(`✅ OTP sent to ${email}: ${otp} (expires: ${otpExpiry.toISOString()})`);

  res.json({
    success: true,
    message: 'Mã OTP đã được gửi đến email của bạn',
    data: {
      email: email,
      expiresIn: 300,
    },
  });
});

/**
 * Step 2: Verify OTP
 * POST /api/auth/verify-otp
 * Body: { email, otp }
 */
const verifyOTP = asyncHandler(async (req, res) => {
  const { email, otp } = req.body;

  // Validate input
  if (!email || !otp) {
    throw new ApiError(400, 'Vui lòng nhập email và mã OTP');
  }

  const otpTrimmed = otp.toString().trim();

  if (otpTrimmed.length !== 6) {
    throw new ApiError(400, 'Mã OTP phải có 6 chữ số');
  }

  // Get user with OTP data
  const [users] = await db.execute(
    `SELECT id, name, email, reset_otp, reset_otp_expiry, reset_otp_attempts 
     FROM users 
     WHERE email = ?`,
    [email.trim().toLowerCase()]
  );

  if (users.length === 0) {
    throw new ApiError(404, 'Không tìm thấy tài khoản');
  }

  const user = users[0];

  // Check if OTP exists
  if (!user.reset_otp) {
    throw new ApiError(400, 'Không tìm thấy mã OTP. Vui lòng yêu cầu mã mới.');
  }

  // Check max attempts
  const maxAttempts = otpService.getMaxAttempts();
  if (user.reset_otp_attempts >= maxAttempts) {
    // Clear OTP after max attempts
    await db.execute(
      'UPDATE users SET reset_otp = NULL, reset_otp_expiry = NULL, reset_otp_attempts = 0 WHERE id = ?',
      [user.id]
    );
    throw new ApiError(429, 'Bạn đã nhập sai quá nhiều lần. Vui lòng yêu cầu mã OTP mới.');
  }

  // Check if OTP expired
  if (!otpService.isOTPValid(user.reset_otp_expiry)) {
    // Clear expired OTP
    await db.execute(
      'UPDATE users SET reset_otp = NULL, reset_otp_expiry = NULL WHERE id = ?',
      [user.id]
    );
    throw new ApiError(400, 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.');
  }

  // Verify OTP
  if (user.reset_otp !== otpTrimmed) {
    // Increment failed attempts
    const newAttempts = user.reset_otp_attempts + 1;
    await db.execute(
      'UPDATE users SET reset_otp_attempts = ? WHERE id = ?',
      [newAttempts, user.id]
    );

    const remainingAttempts = maxAttempts - newAttempts;
    throw new ApiError(
      400,
      `Mã OTP không đúng. Bạn còn ${remainingAttempts} lần thử.`
    );
  }

  // OTP is valid - Clear OTP data (one-time use)
  await db.execute(
    `UPDATE users 
     SET reset_otp_attempts = 0
     WHERE id = ?`,
    [user.id]
  );

  console.log(`✅ OTP verified successfully for ${email}`);

  res.json({
    success: true,
    message: 'Xác thực OTP thành công',
    data: {
      email: email,
      verified: true,
    },
  });
});

/**
 * Step 3: Reset Password
 * POST /api/auth/reset-password
 * Body: { email, otp, newPassword }
 */
const resetPassword = asyncHandler(async (req, res) => {
  const { email, otp, newPassword } = req.body;

  // Validate input
  if (!email || !otp || !newPassword) {
    throw new ApiError(400, 'Vui lòng nhập đầy đủ thông tin');
  }

  const otpTrimmed = otp.toString().trim();

  // Validate password strength
  if (newPassword.length < 8) {
    throw new ApiError(400, 'Mật khẩu phải có ít nhất 8 ký tự');
  }

  // Get user and verify OTP one more time
  const [users] = await db.execute(
    'SELECT id, name, email, password, reset_otp, reset_otp_expiry FROM users WHERE email = ?',
    [email.trim().toLowerCase()]
  );

  if (users.length === 0) {
    throw new ApiError(404, 'Không tìm thấy tài khoản');
  }

  const user = users[0];

  // Verify OTP one final time before password change
  if (!user.reset_otp || user.reset_otp !== otpTrimmed) {
    throw new ApiError(400, 'Mã OTP không hợp lệ. Vui lòng thử lại.');
  }

  if (!otpService.isOTPValid(user.reset_otp_expiry)) {
    throw new ApiError(400, 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.');
  }

  // Check if new password is same as old password
  const isSamePassword = await bcrypt.compare(newPassword, user.password);
  if (isSamePassword) {
    throw new ApiError(400, 'Mật khẩu mới không được trùng với mật khẩu cũ');
  }

  // Hash new password
  const hashedPassword = await bcrypt.hash(newPassword, 10);

  // Update password and clear OTP
  await db.execute(
    `UPDATE users 
     SET password = ?, 
         reset_otp = NULL, 
         reset_otp_expiry = NULL, 
         reset_otp_attempts = 0,
         updated_at = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [hashedPassword, user.id]
  );

  // Send notification email (non-blocking)
  emailService.sendPasswordChangedNotification(email, user.name).catch((err) => {
    console.error('Failed to send notification:', err);
  });

  console.log(`✅ Password reset successfully for ${email}`);

  res.json({
    success: true,
    message: 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập với mật khẩu mới.',
  });
});

// ============================================
// EXPORTS
// ============================================

module.exports = {
  login,
  register,
  updateOnlineStatus,
  // ✅ NEW: Forgot password exports
  forgotPassword,
  verifyOTP,
  resetPassword,
};