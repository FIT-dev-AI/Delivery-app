const axios = require('axios');

// Cấu hình API
const API_BASE_URL = 'http://localhost:3000/api';

// Test data
const testUsers = {
  customer: {
    email: 'an.nguyen@example.com',
    password: '123456'
  },
  shipper: {
    email: 'shipper.tuananh@delivery.com',
    password: '123456'
  },
  admin: {
    email: 'admin@example.com',
    password: '123456'
  }
};

// Helper function để test API
async function testAPI(endpoint, method = 'GET', data = null, token = null) {
  try {
    const config = {
      method,
      url: `${API_BASE_URL}${endpoint}`,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    if (data) {
      config.data = data;
    }

    console.log(`\n🔍 Testing ${method} ${endpoint}`);
    const response = await axios(config);
    
    console.log(`✅ Status: ${response.status}`);
    console.log(`📊 Response:`, JSON.stringify(response.data, null, 2));
    
    return response.data;
  } catch (error) {
    console.log(`❌ Error: ${error.response?.status || error.message}`);
    if (error.response?.data) {
      console.log(`📊 Error Response:`, JSON.stringify(error.response.data, null, 2));
    }
    return null;
  }
}

// Test functions
async function testHealthCheck() {
  console.log('\n🏥 === HEALTH CHECK ===');
  await testAPI('/health', 'GET');
}

async function testAuth() {
  console.log('\n🔐 === AUTHENTICATION TESTS ===');
  
  // Test login với customer
  console.log('\n👤 Testing Customer Login...');
  const customerLogin = await testAPI('/auth/login', 'POST', testUsers.customer);
  
  if (customerLogin?.data?.token) {
    console.log('✅ Customer login successful!');
    
    // Test get orders với customer token
    console.log('\n📦 Testing Customer Orders...');
    await testAPI('/orders', 'GET', null, customerLogin.data.token);
  }
  
  // Test login với shipper
  console.log('\n🚚 Testing Shipper Login...');
  const shipperLogin = await testAPI('/auth/login', 'POST', testUsers.shipper);
  
  if (shipperLogin?.data?.token) {
    console.log('✅ Shipper login successful!');
    
    // Test get orders với shipper token
    console.log('\n📦 Testing Shipper Orders...');
    await testAPI('/orders', 'GET', null, shipperLogin.data.token);
  }
  
  // Test login với admin
  console.log('\n👨‍💼 Testing Admin Login...');
  const adminLogin = await testAPI('/auth/login', 'POST', testUsers.admin);
  
  if (adminLogin?.data?.token) {
    console.log('✅ Admin login successful!');
    
    // Test get orders với admin token
    console.log('\n📦 Testing Admin Orders...');
    await testAPI('/orders', 'GET', null, adminLogin.data.token);
    
    // Test stats dashboard
    console.log('\n📊 Testing Stats Dashboard...');
    await testAPI('/stats/dashboard', 'GET', null, adminLogin.data.token);
  }
}

async function testOrders() {
  console.log('\n📦 === ORDER MANAGEMENT TESTS ===');
  
  // Login để lấy token
  const loginResponse = await testAPI('/auth/login', 'POST', testUsers.customer);
  if (!loginResponse?.data?.token) {
    console.log('❌ Cannot test orders without valid token');
    return;
  }
  
  const token = loginResponse.data.token;
  
  // Test create order
  console.log('\n➕ Testing Create Order...');
  const newOrder = {
    pickup_address: 'Vincom Center, Quận 1',
    pickup_lat: 10.7785,
    pickup_lng: 106.7025,
    delivery_address: 'Crescent Mall, Quận 7',
    delivery_lat: 10.7291,
    delivery_lng: 106.7145,
  };
  
  const createResult = await testAPI('/orders', 'POST', newOrder, token);
  
  if (createResult?.data?.orderId) {
    const orderId = createResult.data.orderId;
    console.log(`✅ Order created with ID: ${orderId}`);
    
    // Test get order by ID
    console.log('\n🔍 Testing Get Order by ID...');
    await testAPI(`/orders/${orderId}`, 'GET', null, token);
  }
}

async function testLocationTracking() {
  console.log('\n📍 === LOCATION TRACKING TESTS ===');
  
  // Login với shipper để test location
  const loginResponse = await testAPI('/auth/login', 'POST', testUsers.shipper);
  if (!loginResponse?.data?.token) {
    console.log('❌ Cannot test location without valid token');
    return;
  }
  
  const token = loginResponse.data.token;
  
  // Test update location
  console.log('\n📍 Testing Update Location...');
  const locationData = {
    latitude: 10.7785,
    longitude: 106.7025,
    accuracy: 10
  };
  
  await testAPI('/tracking/update', 'POST', locationData, token);
}

async function testUserProfile() {
  console.log('\n👤 === USER PROFILE TESTS ===');
  
  // Login để lấy token
  const loginResponse = await testAPI('/auth/login', 'POST', testUsers.customer);
  if (!loginResponse?.data?.token) {
    console.log('❌ Cannot test profile without valid token');
    return;
  }
  
  const token = loginResponse.data.token;
  
  // Test get profile
  console.log('\n👤 Testing Get Profile...');
  await testAPI('/users/profile', 'GET', null, token);
  
  // Test update profile
  console.log('\n✏️ Testing Update Profile...');
  const updateData = {
    name: 'Nguyễn Văn An Updated',
    phone: '0905111222'
  };
  
  await testAPI('/users/profile', 'PUT', updateData, token);
}

// Main test function
async function runAllTests() {
  console.log('🚀 === DELIVERYFLOW API TESTING ===');
  console.log(`📡 Testing API at: ${API_BASE_URL}`);
  
  try {
    await testHealthCheck();
    await testAuth();
    await testOrders();
    await testLocationTracking();
    await testUserProfile();
    
    console.log('\n🎉 === ALL TESTS COMPLETED ===');
    console.log('✅ API testing finished successfully!');
    
  } catch (error) {
    console.log('\n❌ === TEST FAILED ===');
    console.log('Error:', error.message);
  }
}

// Run tests
runAllTests();
