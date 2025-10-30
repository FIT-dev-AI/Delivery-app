const mysql = require('mysql2/promise');
require('dotenv').config();

/**
 * MySQL Connection Pool Configuration
 * Using mysql2/promise for better async/await support
 */
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'delivery_app',
  port: process.env.DB_PORT || 3306,
  
  // Connection pool settings
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  
  // Performance optimization
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  
  // Character set
  charset: 'utf8mb4',
  
  // Timezone
  timezone: '+07:00', // Vietnam timezone
});

/**
 * Test database connection on startup
 */
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✅ Database connection successful');
    console.log(`📊 Database: ${process.env.DB_NAME}`);
    console.log(`🔗 Host: ${process.env.DB_HOST}:${process.env.DB_PORT}`);
    connection.release();
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    process.exit(1); // Exit if cannot connect to database
  }
};

// Run connection test
testConnection();

/**
 * Graceful shutdown
 */
process.on('SIGINT', async () => {
  try {
    await pool.end();
    console.log('🔌 Database pool closed');
    process.exit(0);
  } catch (error) {
    console.error('Error closing database pool:', error);
    process.exit(1);
  }
});

module.exports = pool;