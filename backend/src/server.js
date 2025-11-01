const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

const { errorHandler, errorConverter, notFound } = require('./middleware/errorHandler');

// Import routes
const authRoutes = require('./routes/authRoutes');
const orderRoutes = require('./routes/orderRoutes');
const locationRoutes = require('./routes/locationRoutes');
const statsRoutes = require('./routes/statsRoutes');
const userRoutes = require('./routes/userRoutes');
const adminRoutes = require('./routes/adminRoutes');

const app = express();
const server = http.createServer(app);

// ... (phần setup Socket.io của bạn giữ nguyên) ...
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

app.use(cors());
app.use(express.json({ limit: '50mb' }));

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/tracking', locationRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/users', userRoutes);
app.use('/api/admin', adminRoutes);

// ... (phần Socket.io events của bạn giữ nguyên) ...
io.on('connection', (socket) => {
  console.log('📱 Client kết nối:', socket.id);

  socket.on('joinOrder', (orderId) => {
    socket.join(`order-${orderId}`);
    console.log(`Socket ${socket.id} đã join room: order-${orderId}`);
  });

  socket.on('updateLocation', (data) => {
    const { orderId, shipperId, lat, lng, timestamp } = data;
    io.to(`order-${orderId}`).emit('locationUpdate', {
      shipperId,
      lat,
      lng,
      timestamp
    });
    console.log(`📍 Cập nhật vị trí cho đơn ${orderId}:`, lat, lng);
  });

  socket.on('disconnect', () => {
    console.log('🔴 Client ngắt kết nối:', socket.id);
  });
});


// ===> THÊM PHẦN XỬ LÝ LỖI TẬP TRUNG <===
// Gửi lỗi 404 nếu không có route nào khớp
app.use(notFound);

// Chuyển đổi lỗi thành ApiError (nếu cần)
app.use(errorConverter);

// Middleware xử lý lỗi chính
app.use(errorHandler);

const PORT = process.env.PORT || 3000;
// ... (phần khởi động server của bạn giữ nguyên) ...
// 🌍 Lấy IP address của máy để hiển thị
const os = require('os');
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const interface of interfaces[name]) {
      if (interface.family === 'IPv4' && !interface.internal) {
        return interface.address;
      }
    }
  }
  return 'localhost';
}

const localIP = getLocalIP();

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server đang chạy trên port ${PORT}`);
  console.log(`📡 Local access: http://localhost:${PORT}`);
  console.log(`📱 Network access: http://${localIP}:${PORT}`);
});