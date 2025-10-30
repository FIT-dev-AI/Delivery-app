// backend/config/emailConfig.js
// ✅ Email configuration for password reset

module.exports = {
    // Gmail SMTP settings
    service: 'gmail',
    
    // Authentication
    auth: {
      user: process.env.EMAIL_USER || 'your-email@gmail.com',
      pass: process.env.EMAIL_PASSWORD || 'your-app-password',
    },
    
    // Sender info
    from: {
      name: 'Delivery App',
      email: process.env.EMAIL_USER || 'your-email@gmail.com',
    },
    
    // Email settings
    settings: {
      otpLength: 6,
      otpExpiryMinutes: 5,
      maxOtpAttempts: 5,
    },
  };