/**
 * Async handler wrapper to catch errors in async routes
 * Eliminates need for try-catch in every controller
 * 
 * Usage:
 * router.get('/route', asyncHandler(async (req, res) => {
 *   // Your async code here
 * }));
 */
const asyncHandler = (fn) => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
  
  module.exports = asyncHandler;