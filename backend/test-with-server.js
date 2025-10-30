const { spawn } = require('child_process');
const axios = require('axios');

// Khởi động server
console.log('🚀 Starting server...');
const server = spawn('node', ['src/server.js'], {
  stdio: 'pipe',
  cwd: process.cwd()
});

server.stdout.on('data', (data) => {
  console.log(data.toString());
  
  // Nếu server đã khởi động thành công, test APIs
  if (data.toString().includes('Server đang chạy trên port')) {
    setTimeout(() => {
      testUserAPIs();
    }, 2000);
  }
});

server.stderr.on('data', (data) => {
  console.error('Server error:', data.toString());
});

server.on('close', (code) => {
  console.log(`Server exited with code ${code}`);
});

// Test function
async function testUserAPIs() {
  try {
    console.log('\n=== TEST USER PROFILE APIs ===\n');

    // 1. Login first
    console.log('1. Login...');
    const loginRes = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'testapi@example.com',
      password: '123456'
    });
    
    console.log('Login response:', JSON.stringify(loginRes.data, null, 2));
    
    if (!loginRes.data.success) {
      throw new Error(loginRes.data.message);
    }
    
    const authToken = loginRes.data.token; // Token ở root level
    console.log('✅ Login thành công\n');

    const config = {
      headers: { Authorization: `Bearer ${authToken}` }
    };

    // 2. Get Profile
    console.log('2. Get Profile...');
    const profileRes = await axios.get('http://localhost:3000/api/users/profile', config);
    console.log('✅ Profile:', profileRes.data.data.user);
    console.log();

    // 3. Update Profile
    console.log('3. Update Profile...');
    const updateRes = await axios.put('http://localhost:3000/api/users/profile', {
      name: 'Customer Updated',
      phone: '0979498764'
    }, config);
    console.log('✅ Updated Profile:', updateRes.data.data.user);
    console.log();

    // 4. Change Password (sẽ fail vì wrong current password)
    console.log('4. Change Password (test validation)...');
    try {
      await axios.put('http://localhost:3000/api/users/password', {
        currentPassword: 'wrongpassword',
        newPassword: 'newpass123',
        confirmPassword: 'newpass123'
      }, config);
    } catch (error) {
      console.log('⚠️ Expected error:', error.response.data.message);
    }
    console.log();

    // 5. Get Settings
    console.log('5. Get Settings...');
    const settingsRes = await axios.get('http://localhost:3000/api/users/settings', config);
    console.log('✅ Settings:', settingsRes.data.data.settings);
    console.log();

    // 6. Update Settings
    console.log('6. Update Settings...');
    const updateSettingsRes = await axios.put('http://localhost:3000/api/users/settings', {
      notifications: {
        orderUpdates: false,
        promotions: true,
        newMessages: true
      },
      language: 'en',
      theme: 'dark'
    }, config);
    console.log('✅ Updated Settings:', updateSettingsRes.data.data.settings);

    console.log('\n=== ALL TESTS COMPLETED ✅ ===');
    
    // Tắt server sau khi test xong
    server.kill();
    process.exit(0);
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
    server.kill();
    process.exit(1);
  }
}

// Timeout để tránh treo
setTimeout(() => {
  console.log('⏰ Test timeout - killing server');
  server.kill();
  process.exit(1);
}, 30000);
