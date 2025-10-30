const db = require('./src/config/database');
const bcrypt = require('bcryptjs');

async function testDatabase() {
  try {
    console.log('🔍 Kiểm tra database...');
    
    // 1. Kiểm tra bảng users
    const [users] = await db.execute('SELECT * FROM users LIMIT 5');
    console.log(`👥 Số lượng users: ${users.length}`);
    
    if (users.length > 0) {
      console.log('✅ Sample users:');
      users.forEach(user => {
        console.log(`   - ${user.email} (${user.role})`);
      });
    } else {
      console.log('⚠️  Không có users nào. Đang tạo demo accounts...');
      
      // Tạo demo accounts
      const hashedPassword = await bcrypt.hash('123456', 10);
      
      const demoUsers = [
        ['Customer Demo', 'customer@test.com', hashedPassword, 'customer', '0123456789'],
        ['Shipper Demo', 'shipper@test.com', hashedPassword, 'shipper', '0987654321'],
        ['Admin Demo', 'admin@test.com', hashedPassword, 'admin', '0111222333']
      ];
      
      for (const [name, email, password, role, phone] of demoUsers) {
        await db.execute(
          'INSERT INTO users (name, email, password, role, phone) VALUES (?, ?, ?, ?, ?)',
          [name, email, password, role, phone]
        );
        console.log(`✅ Tạo user: ${email}`);
      }
    }
    
    // 2. Kiểm tra bảng orders
    const [orders] = await db.execute('SELECT COUNT(*) as count FROM orders');
    console.log(`📦 Số lượng orders: ${orders[0].count}`);
    
    // 3. Test API endpoints
    console.log('\n🧪 Testing API endpoints...');
    
    // Test login
    const testLogin = async (email, password) => {
      try {
        const response = await fetch('http://192.168.1.5:3000/api/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password })
        });
        const data = await response.json();
        return data;
      } catch (error) {
        return { success: false, error: error.message };
      }
    };
    
    const loginResult = await testLogin('customer@test.com', '123456');
    if (loginResult.success) {
      console.log('✅ Login API hoạt động');
      console.log(`   Token: ${loginResult.token.substring(0, 20)}...`);
    } else {
      console.log('❌ Login API lỗi:', loginResult.message);
    }
    
    console.log('\n🎉 Database test hoàn thành!');
    
  } catch (error) {
    console.error('❌ Lỗi:', error.message);
  } finally {
    process.exit(0);
  }
}

testDatabase();
