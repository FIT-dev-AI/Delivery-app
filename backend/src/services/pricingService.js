// backend/src/services/pricingService.js
// ✅ Simple pricing calculation service

/**
 * Calculate delivery price based on distance
 * Formula: Base fee (15,000đ) + Distance fee (10,000đ per km)
 */
const calculatePrice = (distanceKm) => {
    const BASE_FEE = 15000;           // Base fee: 15,000 VND
    const PRICE_PER_KM = 10000;       // Per km: 10,000 VND
    const COMMISSION_RATE = 0.20;     // App commission: 20%
  
    const distanceFee = distanceKm * PRICE_PER_KM;
    const totalAmount = BASE_FEE + distanceFee;
    const appCommission = totalAmount * COMMISSION_RATE;
    const shipperAmount = totalAmount - appCommission;
  
    return {
      distanceKm: parseFloat(distanceKm.toFixed(2)),
      baseAmount: BASE_FEE,
      distanceFee: parseFloat(distanceFee.toFixed(0)),
      totalAmount: parseFloat(totalAmount.toFixed(0)),
      shipperAmount: parseFloat(shipperAmount.toFixed(0)),
      appCommission: parseFloat(appCommission.toFixed(0)),
    };
  };
  
  module.exports = {
    calculatePrice,
  };