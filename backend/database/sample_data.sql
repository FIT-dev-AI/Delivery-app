-- SCRIPT TẠO DỮ LIỆU MẪU ĐỒ SỘ CHO DELIVERYFLOW
-- Delivery Management System - Sample Data Generator
-- Created: October 2025

-- Sử dụng database
USE delivery_db;

-- Xóa dữ liệu cũ để tránh xung đột (giữ lại 3 user ban đầu)
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM order_history WHERE order_id > 0;
DELETE FROM locations WHERE shipper_id > 3;
DELETE FROM orders WHERE id > 0;
DELETE FROM users WHERE id > 3;
SET FOREIGN_KEY_CHECKS = 1;

-- Mật khẩu đã được hash cho '123456'
SET @hashed_password = '$2a$10$E9p9s3cT9A.C5xJ5XQ5/A.rG4Hh5eH6K3eJ8mR6zY4z9eH7bC9c6C';

-- TẠO THÊM 10 KHÁCH HÀNG MỚI (IDs từ 4 đến 13)
INSERT INTO users (id, name, email, password, role, phone) VALUES
(4, 'Nguyễn Văn An', 'an.nguyen@example.com', @hashed_password, 'customer', '0905111222'),
(5, 'Trần Thị Bình', 'binh.tran@example.com', @hashed_password, 'customer', '0913222333'),
(6, 'Lê Minh Cường', 'cuong.le@example.com', @hashed_password, 'customer', '0987333444'),
(7, 'Phạm Thuỳ Dung', 'dung.pham@example.com', @hashed_password, 'customer', '0979444555'),
(8, 'Hoàng Văn Giang', 'giang.hoang@example.com', @hashed_password, 'customer', '0358555666'),
(9, 'Vũ Thị Hà', 'ha.vu@example.com', @hashed_password, 'customer', '0369666777'),
(10, 'Đặng Minh Khang', 'khang.dang@example.com', @hashed_password, 'customer', '0868777888'),
(11, 'Bùi Thị Lan', 'lan.bui@example.com', @hashed_password, 'customer', '0836888999'),
(12, 'Hồ Văn Mạnh', 'manh.ho@example.com', @hashed_password, 'customer', '0789999000'),
(13, 'Dương Thị Oanh', 'oanh.duong@example.com', @hashed_password, 'customer', '0778000111');

-- TẠO THÊM 5 SHIPPER MỚI (IDs từ 14 đến 18)
INSERT INTO users (id, name, email, password, role, phone) VALUES
(14, 'Shipper Tuấn Anh', 'shipper.tuananh@delivery.com', @hashed_password, 'shipper', '0909123123'),
(15, 'Shipper Bảo Châu', 'shipper.chau@delivery.com', @hashed_password, 'shipper', '0909456456'),
(16, 'Shipper Minh Đức', 'shipper.duc@delivery.com', @hashed_password, 'shipper', '0909789789'),
(17, 'Shipper Ngọc Lan', 'shipper.lan@delivery.com', @hashed_password, 'shipper', '0909112233'),
(18, 'Shipper Thanh Phong', 'shipper.phong@delivery.com', @hashed_password, 'shipper', '0909445566');

-- TẠO 30 ĐƠN HÀNG VỚI CÁC TRẠNG THÁI KHÁC NHAU
-- Tọa độ ngẫu nhiên xung quanh các quận ở TP.HCM
INSERT INTO orders (customer_id, shipper_id, status, pickup_address, pickup_lat, pickup_lng, delivery_address, delivery_lat, delivery_lng, created_at, updated_at) VALUES
-- 5 Đơn hàng đã giao (delivered)
(4, 14, 'delivered', 'Vincom Center, Quận 1', 10.7785, 106.7025, 'Crescent Mall, Quận 7', 10.7291, 106.7145, NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 22 HOUR),
(5, 15, 'delivered', 'Bitexco Tower, Quận 1', 10.7716, 106.7042, 'SC VivoCity, Quận 7', 10.7328, 106.7001, NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 1 DAY),
(6, 16, 'delivered', 'Landmark 81, Bình Thạnh', 10.7946, 106.7219, 'Đại học RMIT, Quận 7', 10.7289, 106.6943, NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 2 DAY),
(7, 14, 'delivered', 'Sân bay Tân Sơn Nhất', 10.8187, 106.6580, 'Khu công nghệ cao, TP. Thủ Đức', 10.8497, 106.7850, NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 3 DAY),
(8, 15, 'delivered', 'Chợ Bến Thành, Quận 1', 10.7725, 106.6980, 'Giga Mall, TP. Thủ Đức', 10.8256, 106.7181, NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 4 DAY),

-- 5 Đơn hàng đang trên đường (in_transit)
(9, 17, 'in_transit', 'Bệnh viện Chợ Rẫy, Quận 5', 10.7554, 106.6575, 'Bệnh viện FV, Quận 7', 10.7299, 106.7175, NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 1 HOUR),
(10, 18, 'in_transit', 'Dinh Độc Lập, Quận 1', 10.7770, 106.6954, 'Khu đô thị Sala, TP. Thủ Đức', 10.7736, 106.7244, NOW() - INTERVAL 3 HOUR, NOW() - INTERVAL 2 HOUR),
(11, 16, 'in_transit', 'Công viên Tao Đàn, Quận 1', 10.7728, 106.6923, 'Estella Place, TP. Thủ Đức', 10.8016, 106.7335, NOW() - INTERVAL 4 HOUR, NOW() - INTERVAL 1 HOUR),
(12, 17, 'in_transit', 'Nhà hát Lớn, Quận 1', 10.7766, 106.7032, 'Thảo Điền Pearl, TP. Thủ Đức', 10.8037, 106.7235, NOW() - INTERVAL 5 HOUR, NOW() - INTERVAL 3 HOUR),
(13, 18, 'in_transit', 'Phố đi bộ Nguyễn Huệ', 10.7745, 106.7036, 'Vincom Mega Mall, TP. Thủ Đức', 10.8019, 106.7410, NOW() - INTERVAL 6 HOUR, NOW() - INTERVAL 4 HOUR),

-- 5 Đơn hàng đã lấy hàng (picked_up)
(4, 14, 'picked_up', 'Saigon Centre, Quận 1', 10.7720, 106.7029, 'Phú Mỹ Hưng, Quận 7', 10.7323, 106.7171, NOW() - INTERVAL 30 MINUTE, NOW() - INTERVAL 10 MINUTE),
(5, 15, 'picked_up', 'Bảo tàng Chứng tích Chiến tranh', 10.7792, 106.6930, 'Midtown, Quận 7', 10.7350, 106.7210, NOW() - INTERVAL 45 MINUTE, NOW() - INTERVAL 20 MINUTE),
(6, 16, 'picked_up', 'Hồ Con Rùa, Quận 3', 10.7818, 106.6946, 'Sunrise City, Quận 7', 10.7413, 106.6967, NOW() - INTERVAL 1 HOUR, NOW() - INTERVAL 25 MINUTE),
(7, 17, 'picked_up', 'Công viên Lê Văn Tám, Q.Đa Kao', 10.7865, 106.6917, 'Saigon South, H.Bình Chánh', 10.7169, 106.6669, NOW() - INTERVAL 1 HOUR, NOW() - INTERVAL 35 MINUTE),
(8, 18, 'picked_up', 'Thảo Cầm Viên, Quận 1', 10.7858, 106.7052, 'Celadon City, Q.Tân Phú', 10.8021, 106.6190, NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 1 HOUR),

-- 5 Đơn hàng đã phân công (assigned)
(9, 14, 'assigned', 'AEON Mall Bình Tân', 10.7458, 106.6023, 'AEON Mall Tân Phú', 10.8000, 106.6200, NOW() - INTERVAL 15 MINUTE, NOW() - INTERVAL 5 MINUTE),
(10, 15, 'assigned', 'Đầm Sen, Quận 11', 10.7678, 106.6373, 'Suối Tiên, TP. Thủ Đức', 10.8660, 106.7990, NOW() - INTERVAL 25 MINUTE, NOW() - INTERVAL 10 MINUTE),
(11, 16, 'assigned', 'Chung cư The View Riviera Point', 10.7317, 106.7153, 'Chung cư The Sun Avenue', 10.7937, 106.7370, NOW() - INTERVAL 35 MINUTE, NOW() - INTERVAL 15 MINUTE),
(12, 17, 'assigned', 'Đại học Tôn Đức Thắng', 10.7335, 106.6976, 'Đại học HUTECH', 10.8016, 106.7142, NOW() - INTERVAL 55 MINUTE, NOW() - INTERVAL 25 MINUTE),
(13, 18, 'assigned', 'Nowzone, Quận 5', 10.7676, 106.6821, 'Van Hanh Mall, Quận 10', 10.7744, 106.6710, NOW() - INTERVAL 1 HOUR, NOW() - INTERVAL 30 MINUTE),

-- 5 Đơn hàng đang chờ (pending)
(4, NULL, 'pending', 'Bưu điện Trung tâm Sài Gòn', 10.7797, 106.6999, 'Địa chỉ giao hàng A', 10.8221, 106.6297, NOW() - INTERVAL 5 MINUTE, NOW() - INTERVAL 5 MINUTE),
(6, NULL, 'pending', 'Chung cư Vinhomes Central Park', 10.7950, 106.7220, 'Địa chỉ giao hàng B', 10.7626, 106.6823, NOW() - INTERVAL 10 MINUTE, NOW() - INTERVAL 10 MINUTE),
(8, NULL, 'pending', 'Takashimaya, Quận 1', 10.7720, 106.7029, 'Địa chỉ giao hàng C', 10.7757, 106.6322, NOW() - INTERVAL 15 MINUTE, NOW() - INTERVAL 15 MINUTE),
(10, NULL, 'pending', 'Diamond Plaza, Quận 1', 10.7790, 106.6983, 'Địa chỉ giao hàng D', 10.8529, 106.7533, NOW() - INTERVAL 20 MINUTE, NOW() - INTERVAL 20 MINUTE),
(12, NULL, 'pending', 'Independence Palace, Quận 1', 10.7770, 106.6954, 'Địa chỉ giao hàng E', 10.7876, 106.7001, NOW() - INTERVAL 25 MINUTE, NOW() - INTERVAL 25 MINUTE),

-- 5 Đơn hàng đã hủy (cancelled)
(5, 14, 'cancelled', 'Địa chỉ lấy hàng F', 10.7590, 106.6825, 'Địa chỉ giao hàng F', 10.7380, 106.6604, NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 1 DAY),
(7, 15, 'cancelled', 'Địa chỉ lấy hàng G', 10.7900, 106.6950, 'Địa chỉ giao hàng G', 10.8230, 106.6430, NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 2 DAY),
(9, NULL, 'cancelled', 'Địa chỉ lấy hàng H', 10.7700, 106.7000, 'Địa chỉ giao hàng H', 10.7500, 106.6500, NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 3 DAY),
(11, 16, 'cancelled', 'Địa chỉ lấy hàng I', 10.8100, 106.6600, 'Địa chỉ giao hàng I', 10.7400, 106.7100, NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 4 DAY),
(13, 17, 'cancelled', 'Địa chỉ lấy hàng K', 10.8000, 106.7200, 'Địa chỉ giao hàng K', 10.7600, 106.6900, NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 5 DAY);

-- TẠO LỊCH SỬ TRẠNG THÁI VÀ VỊ TRÍ CHO CÁC ĐƠN HÀNG
-- Lưu ý: Đây là dữ liệu giả lập để minh họa
INSERT INTO order_history (order_id, status, notes)
SELECT id, 'pending', 'Khách hàng vừa tạo đơn' FROM orders WHERE status != 'pending';
INSERT INTO order_history (order_id, status, notes)
SELECT id, 'assigned', 'Tài xế đã nhận đơn' FROM orders WHERE status IN ('assigned', 'picked_up', 'in_transit', 'delivered');
INSERT INTO order_history (order_id, status, notes)
SELECT id, 'picked_up', 'Tài xế đã lấy hàng' FROM orders WHERE status IN ('picked_up', 'in_transit', 'delivered');
INSERT INTO order_history (order_id, status, notes)
SELECT id, 'in_transit', 'Đơn hàng đang trên đường giao' FROM orders WHERE status IN ('in_transit', 'delivered');
INSERT INTO order_history (order_id, status, notes)
SELECT id, 'delivered', 'Giao hàng thành công' FROM orders WHERE status = 'delivered';
INSERT INTO order_history (order_id, status, notes)
SELECT id, 'cancelled', 'Đơn hàng đã bị hủy' FROM orders WHERE status = 'cancelled';

-- Tạo vài điểm vị trí cho các đơn hàng đang giao (in_transit)
INSERT INTO locations (shipper_id, order_id, latitude, longitude, accuracy)
SELECT shipper_id, id, pickup_lat + 0.001, pickup_lng + 0.001, 10 FROM orders WHERE status = 'in_transit' AND shipper_id IS NOT NULL
UNION ALL
SELECT shipper_id, id, pickup_lat + 0.005, pickup_lng + 0.005, 8 FROM orders WHERE status = 'in_transit' AND shipper_id IS NOT NULL
UNION ALL
SELECT shipper_id, id, (pickup_lat + delivery_lat) / 2, (pickup_lng + delivery_lng) / 2, 5 FROM orders WHERE status = 'in_transit' AND shipper_id IS NOT NULL;

SELECT 'Tạo dữ liệu mẫu đồ sộ thành công!' AS Status;
