const db = require('../config/database');

const createLocation = async (locationData) => {
  const { shipper_id, latitude, longitude, order_id = null, accuracy = null } = locationData;
  const query = `
    INSERT INTO locations (shipper_id, latitude, longitude, order_id, accuracy)
    VALUES (?, ?, ?, ?, ?)
  `;
  await db.execute(query, [shipper_id, latitude, longitude, order_id, accuracy]);
};

const getLatestShipperLocation = async (shipperId) => {
  const query = `
    SELECT * FROM locations
    WHERE shipper_id = ?
    ORDER BY timestamp DESC
    LIMIT 1
  `;
  const [locations] = await db.execute(query, [shipperId]);
  return locations[0] || null;
};

const getOrderLocationHistory = async (orderId) => {
  // First, get the shipper_id for the given order
  const [orders] = await db.execute('SELECT shipper_id FROM orders WHERE id = ?', [orderId]);
  if (!orders.length || !orders[0].shipper_id) {
    return [];
  }
  const shipperId = orders[0].shipper_id;

  // Then, get the location history for that shipper
  const query = `
    SELECT * FROM locations
    WHERE shipper_id = ?
    ORDER BY timestamp ASC
  `;
  const [locations] = await db.execute(query, [shipperId]);
  return locations;
};

module.exports = {
  createLocation,
  getLatestShipperLocation,
  getOrderLocationHistory,
};