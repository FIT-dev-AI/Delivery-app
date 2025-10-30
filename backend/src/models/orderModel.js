// backend/src/models/orderModel.js
// ✅ UPDATED: Added category and weight field support

const db = require('../config/database');

/**
 * ✅ UPDATED: Add category and weight fields to order creation
 */
const createOrder = async (orderData) => {
  const {
    customer_id,
    pickup_lat,
    pickup_lng,
    pickup_address,
    delivery_lat,
    delivery_lng,
    delivery_address,
    category = 'regular', // ✅ Default to 'regular' if not provided
    weight,               // ✅ NEW: Weight field (required, validated by controller)
    distance_km,
    total_amount,
    shipper_amount,
    app_commission,
    notes
  } = orderData;

  const [result] = await db.execute(
    `INSERT INTO orders (
      customer_id,
      pickup_lat,
      pickup_lng,
      pickup_address,
      delivery_lat,
      delivery_lng,
      delivery_address,
      category,
      weight,
      distance_km,
      total_amount,
      shipper_amount,
      app_commission,
      notes,
      status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')`,
    [
      customer_id,
      pickup_lat,
      pickup_lng,
      pickup_address,
      delivery_lat,
      delivery_lng,
      delivery_address,
      category,     // ✅ Category
      weight,       // ✅ NEW: Weight
      distance_km || 0,
      total_amount || 0,
      shipper_amount || 0,
      app_commission || 0,
      notes || null
    ]
  );

  console.log(`✅ Order #${result.insertId} created by customer #${customer_id} [${category}][${weight}kg]`);
  
  return result.insertId;
};

/**
 * ✅ UPDATED: Include category in order retrieval
 */
const getOrderById = async (orderId) => {
  const [orders] = await db.execute(
    `SELECT o.*, 
            c.name as customer_name, c.phone as customer_phone, c.email as customer_email,
            s.name as shipper_name, s.phone as shipper_phone
     FROM orders o
     LEFT JOIN users c ON o.customer_id = c.id
     LEFT JOIN users s ON o.shipper_id = s.id
     WHERE o.id = ?`,
    [orderId]
  );
  return orders[0];
};

const updateOrderStatus = async (orderId, status, notes = null) => {
  await db.execute('UPDATE orders SET status = ? WHERE id = ?', [status, orderId]);
  await db.execute('INSERT INTO order_history (order_id, status, notes) VALUES (?, ?, ?)', [orderId, status, notes]);
  console.log(`✅ Order #${orderId} status updated to: ${status}`);
  return true;
};

const assignShipper = async (orderId, shipperId) => {
  await db.execute('UPDATE orders SET shipper_id = ?, status = ? WHERE id = ?', [shipperId, 'assigned', orderId]);
  console.log(`✅ Order #${orderId} assigned to shipper #${shipperId}`);
  return true;
};

const updateProofImage = async (orderId, imageBase64) => {
  await db.execute('UPDATE orders SET proof_image_base64 = ?, status = ? WHERE id = ?', [imageBase64, 'delivered', orderId]);
  console.log(`✅ Order #${orderId} marked as delivered with proof image`);
  return true;
};

/**
 * ✅ UPDATED: Include category in customer orders
 */
const getOrdersByCustomer = async (customerId, status = null) => {
  let query = `
    SELECT o.*, c.name as customer_name, s.name as shipper_name
    FROM orders o
    LEFT JOIN users c ON o.customer_id = c.id
    LEFT JOIN users s ON o.shipper_id = s.id
    WHERE o.customer_id = ?
  `;
  const params = [customerId];
  if (status) {
    query += ' AND o.status = ?';
    params.push(status);
  }
  query += ' ORDER BY o.created_at DESC';
  const [orders] = await db.execute(query, params);
  
  console.log(`📊 Customer #${customerId}: ${orders.length} orders returned`);
  
  return orders;
};

/**
 * ✅ UPDATED: Include category in shipper orders with enhanced logging
 */
const getOrdersByShipper = async (shipperId, status = null) => {
  try {
    console.log(`\n🔍 ========== GET ORDERS BY SHIPPER #${shipperId} ==========`);
    
    // ✅ Step 1: Get FRESH shipper status from database
    const [shipperResult] = await db.execute(
      'SELECT id, name, role, is_online FROM users WHERE id = ? AND role = "shipper"',
      [shipperId]
    );
    
    if (!shipperResult || shipperResult.length === 0) {
      console.error(`❌ Shipper #${shipperId} not found in database`);
      return [];
    }
    
    const shipper = shipperResult[0];
    const isOnline = shipper.is_online === 1;
    const statusEmoji = isOnline ? '🟢' : '🔴';
    const statusText = isOnline ? 'ONLINE' : 'OFFLINE';
    
    console.log(`👤 Shipper: ${shipper.name} (#${shipper.id})`);
    console.log(`📍 Status: ${statusEmoji} ${statusText} (is_online = ${shipper.is_online})`);
    
    // ✅ Step 2: Build query based on FRESH online status
    let query = `
      SELECT o.*, 
             c.name as customer_name, 
             c.phone as customer_phone,
             s.name as shipper_name
      FROM orders o
      LEFT JOIN users c ON o.customer_id = c.id
      LEFT JOIN users s ON o.shipper_id = s.id
      WHERE 
    `;
    
    const params = [shipperId];
    
    if (isOnline) {
      // ✅ ONLINE: Show pending orders + assigned orders
      query += `(o.status = 'pending' OR o.shipper_id = ?)`;
      console.log(`🟢 Query Mode: ONLINE (showing pending + assigned orders)`);
    } else {
      // ✅ OFFLINE: Only show assigned/active orders to this shipper
      query += `o.shipper_id = ? AND o.status IN ('assigned', 'picked_up', 'in_transit')`;
      console.log(`🔴 Query Mode: OFFLINE (showing only active orders)`);
    }
    
    // ✅ Step 3: Apply status filter if provided
    if (status) {
      query += ' AND o.status = ?';
      params.push(status);
      console.log(`📝 Additional Filter: status = '${status}'`);
    }
    
    query += ' ORDER BY o.created_at DESC';
    
    // ✅ Step 4: Execute query
    console.log(`📊 Executing query...`);
    const [orders] = await db.execute(query, params);
    
    console.log(`📊 Result: ${orders.length} order(s) returned`);
    
    // ✅ Step 5: Show order details including category and weight
    if (orders.length > 0) {
      const orderDetails = orders.map(o => 
        `#${o.id} [${o.status}][${o.category}][${o.weight}kg]${o.shipper_id === shipperId ? ' (yours)' : ''}`
      ).join(', ');
      console.log(`   📋 Orders: ${orderDetails}`);
    } else {
      console.log(`   ⚠️ No orders found`);
      
      // ✅ Step 6: Debug - Check if there are pending orders in system
      if (isOnline) {
        const [allPending] = await db.execute(
          'SELECT COUNT(*) as count FROM orders WHERE status = "pending"'
        );
        const pendingCount = allPending[0].count;
        console.log(`   🔍 Debug: Total pending orders in system: ${pendingCount}`);
        
        if (pendingCount > 0) {
          // Show sample pending orders for debugging
          const [sampleOrders] = await db.execute(
            'SELECT id, customer_id, category, weight, created_at FROM orders WHERE status = "pending" ORDER BY created_at DESC LIMIT 3'
          );
          console.log(`   🔍 Sample pending orders:`);
          sampleOrders.forEach(o => {
            console.log(`      - Order #${o.id} [${o.category}][${o.weight}kg] (customer #${o.customer_id})`);
          });
        }
      }
    }
    
    console.log(`========== END GET ORDERS BY SHIPPER #${shipperId} ==========\n`);
    
    return orders;
  } catch (error) {
    console.error(`❌ Error in getOrdersByShipper for shipper #${shipperId}:`, error);
    throw error;
  }
};

/**
 * ✅ UPDATED: Include category in admin orders
 */
const getAllOrders = async (status = null) => {
  let query = `
    SELECT o.*, c.name as customer_name, s.name as shipper_name
    FROM orders o
    LEFT JOIN users c ON o.customer_id = c.id
    LEFT JOIN users s ON o.shipper_id = s.id
  `;
  const params = [];
  if (status) {
    query += ' WHERE o.status = ?';
    params.push(status);
  }
  query += ' ORDER BY o.created_at DESC';
  const [orders] = await db.execute(query, params);
  
  console.log(`📊 Admin: ${orders.length} total orders returned`);
  
  return orders;
};

/**
 * ✅ Get active orders for a shipper (includes category and weight)
 */
const getActiveOrdersByShipper = async (shipperId) => {
  const query = `
    SELECT o.*, 
           c.name as customer_name, 
           c.phone as customer_phone,
           c.email as customer_email
    FROM orders o
    LEFT JOIN users c ON o.customer_id = c.id
    WHERE o.shipper_id = ? 
    AND o.status IN ('assigned', 'picked_up', 'in_transit')
    ORDER BY o.created_at DESC
  `;
  const [orders] = await db.execute(query, [shipperId]);
  
  console.log(`📊 Shipper #${shipperId}: ${orders.length} active order(s)`);
  
  return orders;
};

/**
 * ✅ Cancel order by shipper
 */
const cancelOrderByShipper = async (orderId, shipperId, cancelReason) => {
  // Validate ownership and status
  const [orders] = await db.execute(
    'SELECT * FROM orders WHERE id = ? AND shipper_id = ? AND status = ?',
    [orderId, shipperId, 'assigned']
  );
  
  if (orders.length === 0) {
    console.error(`❌ Cannot cancel order #${orderId}: Not found or invalid status`);
    throw new Error('Không thể hủy đơn hàng này');
  }

  // Release order back to pool
  await db.execute(
    'UPDATE orders SET shipper_id = NULL, status = ? WHERE id = ?',
    ['pending', orderId]
  );

  // ✅ Log history with shipper_id for tracking
  await db.execute(
    'INSERT INTO order_history (order_id, shipper_id, status, notes) VALUES (?, ?, ?, ?)',
    [orderId, shipperId, 'cancelled_by_shipper', `[Shipper hủy]: ${cancelReason}`]
  );

  console.log(`✅ Order #${orderId} cancelled by shipper #${shipperId} and returned to pending`);

  return true;
};

module.exports = {
  createOrder,
  getOrderById,
  updateOrderStatus,
  assignShipper,
  updateProofImage,
  getOrdersByCustomer,
  getOrdersByShipper,
  getAllOrders,
  getActiveOrdersByShipper,
  cancelOrderByShipper,
};