// backend/src/utils/pricingCalculator.js
// 💰 PRICING CALCULATION UTILITY

/**
 * Pricing constants
 */
const PRICING_CONFIG = {
    PRICE_PER_KM: 10000,        // 10,000 VNĐ per km
    SHIPPER_COMMISSION: 0.70,   // 70% for shipper
    APP_COMMISSION: 0.30,       // 30% for app
    MIN_DISTANCE: 0.5,          // Minimum billable distance (km)
    MIN_AMOUNT: 5000,           // Minimum charge (VNĐ)
  };
  
  /**
   * Calculate pricing based on distance
   * @param {number} distanceKm - Distance in kilometers
   * @returns {object} Pricing breakdown
   */
  function calculatePricing(distanceKm) {
    // Validate input
    if (typeof distanceKm !== 'number' || distanceKm < 0) {
      throw new Error('Invalid distance: must be a positive number');
    }
  
    // Round distance to 2 decimal places
    const distance = Math.round(distanceKm * 100) / 100;
  
    // Apply minimum distance
    const billableDistance = Math.max(distance, PRICING_CONFIG.MIN_DISTANCE);
  
    // Calculate amounts
    let totalAmount = billableDistance * PRICING_CONFIG.PRICE_PER_KM;
    
    // Apply minimum charge
    totalAmount = Math.max(totalAmount, PRICING_CONFIG.MIN_AMOUNT);
  
    const shipperAmount = Math.round(totalAmount * PRICING_CONFIG.SHIPPER_COMMISSION);
    const appCommission = Math.round(totalAmount * PRICING_CONFIG.APP_COMMISSION);
  
    // Adjust total to match shipper + commission (handle rounding)
    const adjustedTotal = shipperAmount + appCommission;
  
    return {
      distance_km: distance,
      total_amount: adjustedTotal,
      shipper_amount: shipperAmount,
      app_commission: appCommission,
    };
  }
  
  /**
   * Format amount to VND currency string
   * @param {number} amount - Amount in VND
   * @returns {string} Formatted currency string
   */
  function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
    }).format(amount);
  }
  
  /**
   * Get pricing summary text
   * @param {object} pricing - Pricing object from calculatePricing
   * @returns {string} Summary text
   */
  function getPricingSummary(pricing) {
    return `Khoảng cách: ${pricing.distance_km} km | ` +
           `Tổng: ${formatCurrency(pricing.total_amount)} | ` +
           `Shipper nhận: ${formatCurrency(pricing.shipper_amount)}`;
  }
  
  module.exports = {
    PRICING_CONFIG,
    calculatePricing,
    formatCurrency,
    getPricingSummary,
  };