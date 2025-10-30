const statsModel = require('../models/statsModel');
const asyncHandler = require('../utils/asyncHandler');

const getDashboard = asyncHandler(async (req, res) => {
  const stats = await statsModel.getDashboardStats(req.user);
  res.json({
    success: true,
    message: 'Lấy thống kê thành công',
    data: stats,
  });
});

module.exports = { getDashboard };
