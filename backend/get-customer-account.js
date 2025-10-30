const db = require('./src/config/database');

async function getCustomerAccounts() {
  try {
    console.log('🔍 Lấy thông tin tài khoản khách hàng...\n');
    
    // Lấy tất cả tài khoản customer
    const [customers] = await db.execute(
      "SELECT id, name, email, role, phone, created_at FROM users WHERE role = 'customer' ORDER BY id"
    );
    
    if (customers.length > 0) {
      console.log('👥 DANH SÁCH TÀI KHOẢN KHÁCH HÀNG:');
      console.log('=====================================');
      
      customers.forEach((customer, index) => {
        console.log(`\n📋 Tài khoản ${index + 1}:`);
        console.log(`   👤 Tên: ${customer.name}`);
        console.log(`   📧 Email: ${customer.email}`);
        console.log(`   🔑 Mật khẩu: 123456`);
        console.log(`   👨‍💼 Vai trò: ${customer.role}`);
        console.log(`   📱 Số điện thoại: ${customer.phone}`);
        console.log(`   📅 Tạo lúc: ${customer.created_at}`);
      });
      
      console.log('\n🎯 THÔNG TIN ĐĂNG NHẬP:');
      console.log('=====================================');
      console.log(`📧 Email: ${customers[0].email}`);
      console.log(`🔑 Mật khẩu: 123456`);
      console.log(`👨‍💼 Vai trò: customer`);
      
      console.log('\n💡 LƯU Ý:');
      console.log('- Tất cả tài khoản demo đều có mật khẩu: 123456');
      console.log('- Có thể sử dụng bất kỳ email nào trong danh sách trên');
      console.log('- Hoặc tạo tài khoản mới qua màn hình Register');
      
    } else {
      console.log('⚠️  Không tìm thấy tài khoản customer nào!');
      console.log('💡 Hãy tạo tài khoản mới qua màn hình Register trong app');
    }
    
  } catch (error) {
    console.error('❌ Lỗi:', error.message);
  } finally {
    process.exit(0);
  }
}

getCustomerAccounts();
