try {
  console.log('--- Bắt đầu kiểm tra file controller ---');
  const orderController = require('./src/controllers/orderController.js');
  if (orderController && typeof orderController.updateStatus === 'function') {
    console.log('✅ THÀNH CÔNG! File orderController.js đã được load.');
    console.log('Hàm updateStatus: [Function]');
  } else if (orderController) {
    console.log('⚠️ LỖI LẠ: File controller load được nhưng không tìm thấy hàm updateStatus.');
    console.log('Các hàm tìm thấy:', Object.keys(orderController));
  } else {
    console.log('⚠️ LỖI LẠ: File controller load được nhưng là một object rỗng.');
  }
} catch (error) {
  console.log('❌ LỖI GỐC ĐÃ ĐƯỢC TÌM THẤY (Đây chính là lỗi thật):');
  console.error(error);
}
