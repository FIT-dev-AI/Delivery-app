import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/constants/api_constants.dart';

class SocketService {
  io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // Kết nối tới server
  void connect() {
    if (_socket != null && _isConnected) {
      debugPrint('🔌 Socket đã kết nối');
      return;
    }

    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('✅ Socket kết nối thành công');
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Socket ngắt kết nối');
      _isConnected = false;
    });

    _socket!.onError((error) {
      debugPrint('⚠️ Socket error: $error');
    });
  }

  // Join vào room của đơn hàng
  void joinOrder(int orderId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('joinOrder', orderId);
      debugPrint('📍 Joined room: order-$orderId');
    }
  }

  // Leave room của đơn hàng
  void leaveOrder(int orderId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leaveOrder', orderId);
      debugPrint('🚪 Left room: order-$orderId');
    }
  }

  // Gửi cập nhật vị trí (từ shipper)
  void updateLocation({
    required int orderId,
    required int shipperId,
    required double lat,
    required double lng,
  }) {
    if (_socket != null && _isConnected) {
      _socket!.emit('updateLocation', {
        'orderId': orderId,
        'shipperId': shipperId,
        'lat': lat,
        'lng': lng,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('📍 Đã gửi vị trí: $lat, $lng');
    }
  }

  // Lắng nghe cập nhật vị trí
  void listenToLocationUpdates(Function(Map<String, dynamic>) callback) {
    if (_socket != null) {
      _socket!.on('locationUpdate', (data) {
        debugPrint('📥 Nhận cập nhật vị trí: $data');
        callback(data);
      });
    }
  }

  // Lắng nghe cập nhật trạng thái đơn hàng
  void listenToOrderUpdates(Function(Map<String, dynamic>) callback) {
    if (_socket != null) {
      _socket!.on('orderStatusUpdate', (data) {
        debugPrint('📦 Nhận cập nhật đơn hàng: $data');
        callback(data);
      });
    }
  }

  // Gửi thông báo trạng thái đơn hàng
  void sendOrderUpdate({
    required int orderId,
    required String status,
    String? notes,
  }) {
    if (_socket != null && _isConnected) {
      _socket!.emit('orderUpdate', {
        'orderId': orderId,
        'status': status,
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('📦 Đã gửi cập nhật đơn hàng: $status');
    }
  }

  // Kiểm tra kết nối và tự động kết nối lại
  void ensureConnection() {
    if (_socket == null || !_isConnected) {
      debugPrint('🔄 Đang kết nối lại socket...');
      connect();
    }
  }

  // Ngắt kết nối
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      debugPrint('🔌 Socket đã ngắt kết nối');
    }
  }

  // Cleanup
  void dispose() {
    disconnect();
  }
}
