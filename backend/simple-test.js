const axios = require('axios');

async function simpleTest() {
  try {
    console.log('Testing connection to server...');
    
    const response = await axios.get('http://localhost:3000/api/auth/test');
    console.log('✅ Server is running:', response.data);
  } catch (error) {
    console.log('❌ Connection failed:', error.message);
    
    if (error.code === 'ECONNREFUSED') {
      console.log('💡 Server is not running. Please start server first.');
    } else if (error.response) {
      console.log('📡 Server responded with status:', error.response.status);
    }
  }
}

simpleTest();
