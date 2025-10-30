// backend/models/statsModel.js
// ✅ SIMPLIFIED: Count cancelled from order_history with shipper_id

const db = require('../config/database');

const getDashboardStats = async (user) => {
  const { id: userId, role } = user;
  
  // Order Counts Query
  let countQuery = `
    SELECT
      COUNT(*) AS totalOrders,
      SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
      SUM(CASE WHEN status = 'assigned' THEN 1 ELSE 0 END) AS assigned,
      SUM(CASE WHEN status = 'picked_up' THEN 1 ELSE 0 END) AS picked_up,
      SUM(CASE WHEN status = 'in_transit' THEN 1 ELSE 0 END) AS in_transit,
      SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS delivered,
      SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled
    FROM orders
  `;
  
  // Revenue Query
  let revenueQuery = `
    SELECT
      COALESCE(SUM(CASE 
        WHEN status = 'delivered' 
        AND YEAR(created_at) = YEAR(CURRENT_DATE())
        AND MONTH(created_at) = MONTH(CURRENT_DATE())
        THEN ${role === 'shipper' ? 'shipper_amount' : 'total_amount'}
        ELSE 0
      END), 0) AS monthRevenue,
      COALESCE(SUM(CASE 
        WHEN status = 'delivered'
        AND YEAR(created_at) = YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
        AND MONTH(created_at) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
        THEN ${role === 'shipper' ? 'shipper_amount' : 'total_amount'}
        ELSE 0
      END), 0) AS lastMonthRevenue
    FROM orders
  `;
  
  // ✅ NEW: Cancelled by Shipper Query (SIMPLE!)
  let cancelledQuery = `
    SELECT COUNT(*) AS cancelledByShipper
    FROM order_history
    WHERE status = 'cancelled_by_shipper'
  `;
  
  const params = [];
  const cancelledParams = [];

  // Add WHERE clause based on role
  if (role === 'customer') {
    countQuery += ' WHERE customer_id = ?';
    revenueQuery += ' WHERE customer_id = ?';
    cancelledQuery += ' AND order_id IN (SELECT id FROM orders WHERE customer_id = ?)';
    params.push(userId);
    cancelledParams.push(userId);
  } else if (role === 'shipper') {
    countQuery += ' WHERE shipper_id = ?';
    revenueQuery += ' WHERE shipper_id = ?';
    cancelledQuery += ' AND shipper_id = ?'; // ✅ Simple!
    params.push(userId);
    cancelledParams.push(userId);
  }

  // Execute queries
  const [countStats] = await db.execute(countQuery, params);
  const [revenueStats] = await db.execute(revenueQuery, params);
  const [cancelledStats] = await db.execute(cancelledQuery, cancelledParams); // ✅ NEW

  // Calculate revenue growth
  const monthRevenue = parseFloat(revenueStats[0].monthRevenue) || 0;
  const lastMonthRevenue = parseFloat(revenueStats[0].lastMonthRevenue) || 0;
  
  let revenueGrowth = 0;
  if (lastMonthRevenue > 0) {
    revenueGrowth = ((monthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
  } else if (monthRevenue > 0) {
    revenueGrowth = 100;
  }

  // ✅ Combine results
  const cancelledByShipper = parseInt(cancelledStats[0]?.cancelledByShipper) || 0;

  return {
    // Order counts
    totalOrders: parseInt(countStats[0].totalOrders) || 0,
    pending: parseInt(countStats[0].pending) || 0,
    assigned: parseInt(countStats[0].assigned) || 0,
    picked_up: parseInt(countStats[0].picked_up) || 0,
    in_transit: parseInt(countStats[0].in_transit) || 0,
    delivered: parseInt(countStats[0].delivered) || 0,
    cancelled: parseInt(countStats[0].cancelled) + cancelledByShipper, // ✅ Add cancelled by shipper
    
    // Revenue data
    revenue: monthRevenue,
    totalSpent: monthRevenue,
    monthRevenue: monthRevenue,
    lastMonthRevenue: lastMonthRevenue,
    revenueGrowth: parseFloat(revenueGrowth.toFixed(1)),
  };
};

module.exports = {
  getDashboardStats,
};