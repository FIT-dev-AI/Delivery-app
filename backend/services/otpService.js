// backend/services/otpService.js
// ✅ OTP generation and validation logic

const emailConfig = require('../src/config/emailConfig');

class OTPService {
  /**
   * Generate random 6-digit OTP
   * @returns {string} 6-digit OTP
   */
  generateOTP() {
    const length = emailConfig.settings.otpLength;
    const min = Math.pow(10, length - 1);
    const max = Math.pow(10, length) - 1;
    const otp = Math.floor(min + Math.random() * (max - min + 1));
    return otp.toString();
  }

  /**
   * Get OTP expiry time (current time + 5 minutes)
   * @returns {Date} Expiry timestamp
   */
  getOTPExpiry() {
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + emailConfig.settings.otpExpiryMinutes);
    return expiry;
  }

  /**
   * Check if OTP is still valid (not expired)
   * @param {Date|string} expiryTime - OTP expiry timestamp
   * @returns {boolean} True if valid, false if expired
   */
  isOTPValid(expiryTime) {
    if (!expiryTime) return false;
    const now = new Date();
    const expiry = new Date(expiryTime);
    return now < expiry;
  }

  /**
   * Get remaining seconds until OTP expires
   * @param {Date|string} expiryTime - OTP expiry timestamp
   * @returns {number} Remaining seconds (0 if expired)
   */
  getRemainingSeconds(expiryTime) {
    if (!expiryTime) return 0;
    const now = new Date();
    const expiry = new Date(expiryTime);
    const diffMs = expiry - now;
    return Math.max(0, Math.floor(diffMs / 1000));
  }

  /**
   * Format OTP for display (XXX-XXX)
   * @param {string} otp - 6-digit OTP
   * @returns {string} Formatted OTP
   */
  formatOTP(otp) {
    if (!otp || otp.length !== 6) return otp;
    return `${otp.substring(0, 3)}-${otp.substring(3)}`;
  }

  /**
   * Get max allowed attempts
   * @returns {number} Max attempts
   */
  getMaxAttempts() {
    return emailConfig.settings.maxOtpAttempts;
  }
}

module.exports = new OTPService();