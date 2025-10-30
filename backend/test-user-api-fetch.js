// Test User Profile APIs với fetch thay vì axios
async function testUserAPIsWithFetch() {
  try {
    console.log('=== TEST USER PROFILE APIs (with fetch) ===\n');

    // 1. Login first
    console.log('1. Login...');
    try {
      const loginRes = await fetch('http://localhost:3000/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: 'customer@test.com',
          password: '123456'
        })
      });

      if (!loginRes.ok) {
        throw new Error(`HTTP ${loginRes.status}: ${loginRes.statusText}`);
      }

      const loginData = await loginRes.json();
      authToken = loginData.data.token;
      console.log('✅ Login thành công\n');
    } catch (loginError) {
      console.error('❌ Login failed:', loginError.message);
      console.log('💡 Hãy đảm bảo server đang chạy và có user customer@test.com trong database');
      return;
    }

    const config = {
      headers: { 
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      }
    };

    // 2. Get Profile
    console.log('2. Get Profile...');
    const profileRes = await fetch('http://localhost:3000/api/users/profile', {
      method: 'GET',
      headers: config.headers
    });
    const profileData = await profileRes.json();
    console.log('✅ Profile:', profileData.data.user);
    console.log();

    // 3. Update Profile
    console.log('3. Update Profile...');
    const updateRes = await fetch('http://localhost:3000/api/users/profile', {
      method: 'PUT',
      headers: config.headers,
      body: JSON.stringify({
        name: 'Customer Updated',
        phone: '0979498764'
      })
    });
    const updateData = await updateRes.json();
    console.log('✅ Updated Profile:', updateData.data.user);
    console.log();

    // 4. Change Password (sẽ fail vì wrong current password)
    console.log('4. Change Password (test validation)...');
    try {
      const passwordRes = await fetch('http://localhost:3000/api/users/password', {
        method: 'PUT',
        headers: config.headers,
        body: JSON.stringify({
          currentPassword: 'wrongpassword',
          newPassword: 'newpass123',
          confirmPassword: 'newpass123'
        })
      });
      const passwordData = await passwordRes.json();
      console.log('✅ Password changed:', passwordData.message);
    } catch (error) {
      console.log('⚠️ Expected error:', error.message);
    }
    console.log();

    // 5. Get Settings
    console.log('5. Get Settings...');
    const settingsRes = await fetch('http://localhost:3000/api/users/settings', {
      method: 'GET',
      headers: config.headers
    });
    const settingsData = await settingsRes.json();
    console.log('✅ Settings:', settingsData.data.settings);
    console.log();

    // 6. Update Settings
    console.log('6. Update Settings...');
    const updateSettingsRes = await fetch('http://localhost:3000/api/users/settings', {
      method: 'PUT',
      headers: config.headers,
      body: JSON.stringify({
        notifications: {
          orderUpdates: false,
          promotions: true,
          newMessages: true
        },
        language: 'en',
        theme: 'dark'
      })
    });
    const updateSettingsData = await updateSettingsRes.json();
    console.log('✅ Updated Settings:', updateSettingsData.data.settings);

    console.log('\n=== ALL TESTS COMPLETED ✅ ===');
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

let authToken = '';
testUserAPIsWithFetch();
