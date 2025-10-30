const axios = require('axios');

const API_BASE = 'http://localhost:3000/api';
let authToken = '';

async function testUserAPIs() {
  try {
    console.log('=== TEST USER PROFILE APIs ===\n');

    // 1. Login first
    console.log('1. Login...');
    try {
      const loginRes = await axios.post(`${API_BASE}/auth/login`, {
        email: 'customer@test.com',
        password: '123456'
      });
      authToken = loginRes.data.data.token;
      console.log('✅ Login thành công\n');
    } catch (loginError) {
      console.error('❌ Login failed:');
      console.error('   Error:', loginError.message);
      if (loginError.response) {
        console.error('   Status:', loginError.response.status);
        console.error('   Data:', loginError.response.data);
      }
      console.log('💡 Hãy đảm bảo server đang chạy và có user customer@test.com trong database');
      return;
    }

    const config = {
      headers: { Authorization: `Bearer ${authToken}` }
    };

    // 2. Get Profile
    console.log('2. Get Profile...');
    const profileRes = await axios.get(`${API_BASE}/users/profile`, config);
    console.log('✅ Profile:', profileRes.data.data.user);
    console.log();

    // 3. Update Profile
    console.log('3. Update Profile...');
    const updateRes = await axios.put(`${API_BASE}/users/profile`, {
      name: 'Tai Updated',
      phone: '0979498764'
    }, config);
    console.log('✅ Updated Profile:', updateRes.data.data.user);
    console.log();

    // 4. Change Password (sẽ fail vì wrong current password)
    console.log('4. Change Password (test validation)...');
    try {
      await axios.put(`${API_BASE}/users/password`, {
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
    const settingsRes = await axios.get(`${API_BASE}/users/settings`, config);
    console.log('✅ Settings:', settingsRes.data.data.settings);
    console.log();

    // 6. Update Settings
    console.log('6. Update Settings...');
    const updateSettingsRes = await axios.put(`${API_BASE}/users/settings`, {
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
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

testUserAPIs();
