const locationModel = require('../models/locationModel');
const asyncHandler = require('../utils/asyncHandler');
const { ApiError } = require('../middleware/errorHandler');

const updateLocation = asyncHandler(async (req, res) => {
  const locationData = { shipper_id: req.user.id, ...req.body };
  await locationModel.createLocation(locationData);
  res.json({ success: true, message: 'Cập nhật vị trí thành công' });
});

const getShipperLocation = asyncHandler(async (req, res) => {
  const location = await locationModel.getLatestShipperLocation(req.params.shipperId);
  res.json({ success: true, data: { location } });
});

const getLocationHistory = asyncHandler(async (req, res) => {
  const locations = await locationModel.getOrderLocationHistory(req.params.orderId);
  res.json({ success: true, data: { locations } });
});

module.exports = {
  updateLocation,
  getShipperLocation,
  getLocationHistory,
};
