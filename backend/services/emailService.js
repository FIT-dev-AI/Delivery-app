// backend/services/emailService.js
// ✅ Email service for sending OTP and notifications

const nodemailer = require('nodemailer');
const emailConfig = require('../src/config/emailConfig');

class EmailService {
  constructor() {
    // Create transporter
    this.transporter = nodemailer.createTransport({
      service: emailConfig.service,
      auth: emailConfig.auth,
    });

    // Verify connection on startup
    this.verifyConnection();
  }

  // Verify SMTP connection
  async verifyConnection() {
    try {
      await this.transporter.verify();
      console.log('✅ Email service connected successfully');
    } catch (error) {
      console.error('❌ Email service connection failed:', error.message);
      console.error('   Please check your EMAIL_USER and EMAIL_PASSWORD in .env');
    }
  }

  // Send OTP email
  async sendOTP(email, otp, userName = 'Người dùng') {
    const mailOptions = {
      from: `${emailConfig.from.name} <${emailConfig.from.email}>`,
      to: email,
      subject: '🔐 Mã OTP đặt lại mật khẩu - Delivery App',
      html: this.getOTPEmailTemplate(otp, userName),
    };

    try {
      const info = await this.transporter.sendMail(mailOptions);
      console.log(`✅ OTP email sent to ${email}: ${info.messageId}`);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('❌ Failed to send OTP email:', error);
      throw new Error('Không thể gửi email. Vui lòng thử lại sau.');
    }
  }

  // Send password changed notification
  async sendPasswordChangedNotification(email, userName = 'Người dùng') {
    const mailOptions = {
      from: `${emailConfig.from.name} <${emailConfig.from.email}>`,
      to: email,
      subject: '✅ Mật khẩu đã được thay đổi - Delivery App',
      html: this.getPasswordChangedTemplate(userName),
    };

    try {
      const info = await this.transporter.sendMail(mailOptions);
      console.log(`✅ Password changed notification sent to ${email}`);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('❌ Failed to send notification:', error);
      // Don't throw - notification failure shouldn't block password reset
    }
  }

  // OTP Email Template
  getOTPEmailTemplate(otp, userName) {
    return `
      <!DOCTYPE html>
      <html lang="vi">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6; 
            color: #333;
            background-color: #f5f5f5;
          }
          .container { 
            max-width: 600px; 
            margin: 40px auto; 
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
          }
          .header { 
            background: linear-gradient(135deg, #FF5722 0%, #FF8A50 100%);
            padding: 40px 30px;
            text-align: center;
          }
          .header h1 { 
            color: white; 
            font-size: 28px;
            margin: 0;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
          .content { 
            padding: 40px 30px;
          }
          .greeting {
            font-size: 18px;
            margin-bottom: 20px;
            color: #2c3e50;
          }
          .otp-box { 
            background: linear-gradient(135deg, #fff5f2 0%, #ffe8e0 100%);
            border: 2px dashed #FF5722;
            padding: 30px;
            text-align: center;
            margin: 30px 0;
            border-radius: 12px;
          }
          .otp-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
          }
          .otp-code { 
            font-size: 48px;
            font-weight: bold;
            color: #FF5722;
            letter-spacing: 12px;
            font-family: 'Courier New', monospace;
            margin: 10px 0;
          }
          .otp-expiry {
            font-size: 14px;
            color: #666;
            margin-top: 15px;
          }
          .warning { 
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 20px;
            margin: 30px 0;
            border-radius: 4px;
          }
          .warning-title {
            font-weight: bold;
            color: #856404;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
          }
          .warning ul {
            margin: 10px 0 0 0;
            padding-left: 20px;
            color: #856404;
          }
          .warning li {
            margin: 8px 0;
          }
          .footer { 
            text-align: center;
            padding: 30px;
            background: #f8f9fa;
            color: #666;
            font-size: 13px;
          }
          .footer-brand {
            font-weight: bold;
            color: #FF5722;
            margin-bottom: 10px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🚚 Delivery App</h1>
          </div>
          <div class="content">
            <p class="greeting">Xin chào <strong>${userName}</strong>!</p>
            <p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản Delivery App. Đây là mã OTP của bạn:</p>
            
            <div class="otp-box">
              <div class="otp-label">Mã OTP của bạn</div>
              <div class="otp-code">${otp}</div>
              <div class="otp-expiry">
                ⏱️ Mã này có hiệu lực trong <strong>5 phút</strong>
              </div>
            </div>
            
            <div class="warning">
              <div class="warning-title">⚠️ Lưu ý bảo mật quan trọng</div>
              <ul>
                <li><strong>Không chia sẻ</strong> mã OTP này với bất kỳ ai</li>
                <li>Nhân viên Delivery App <strong>không bao giờ</strong> hỏi mã OTP qua điện thoại hay email</li>
                <li>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng <strong>bỏ qua</strong> email này</li>
                <li>Liên hệ ngay với chúng tôi nếu bạn nghi ngờ tài khoản bị xâm nhập</li>
              </ul>
            </div>
            
            <p style="margin-top: 30px;">Trân trọng,<br><strong>Đội ngũ Delivery App</strong></p>
          </div>
          <div class="footer">
            <div class="footer-brand">Delivery App</div>
            <p>Email này được gửi tự động, vui lòng không reply.</p>
            <p style="margin-top: 10px;">&copy; 2025 Delivery App. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  // Password Changed Template
  getPasswordChangedTemplate(userName) {
    const now = new Date().toLocaleString('vi-VN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });

    return `
      <!DOCTYPE html>
      <html lang="vi">
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 40px auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
          .header { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); padding: 40px 30px; text-align: center; }
          .header h1 { color: white; margin: 0; }
          .content { padding: 40px 30px; }
          .success-box { background: #d4edda; border-left: 4px solid #28a745; padding: 20px; margin: 20px 0; border-radius: 4px; }
          .warning-box { background: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; margin: 20px 0; border-radius: 4px; }
          .footer { text-align: center; padding: 30px; background: #f8f9fa; color: #666; font-size: 13px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✅ Mật khẩu đã được cập nhật</h1>
          </div>
          <div class="content">
            <p>Xin chào <strong>${userName}</strong>!</p>
            <div class="success-box">
              <strong>✅ Mật khẩu đã thay đổi thành công</strong>
              <p style="margin: 10px 0 0 0;">Thời gian: ${now}</p>
            </div>
            <p>Tài khoản Delivery App của bạn đã được bảo mật với mật khẩu mới.</p>
            <div class="warning-box">
              <strong>⚠️ Nếu không phải bạn thực hiện:</strong>
              <p style="margin: 10px 0 0 0;">Vui lòng liên hệ ngay với chúng tôi để bảo vệ tài khoản của bạn.</p>
            </div>
            <p>Trân trọng,<br><strong>Đội ngũ Delivery App</strong></p>
          </div>
          <div class="footer">
            <p>Email này được gửi tự động, vui lòng không reply.</p>
            <p>&copy; 2025 Delivery App. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }
}

module.exports = new EmailService();


