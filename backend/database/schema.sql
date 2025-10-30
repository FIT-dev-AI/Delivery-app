-- Database schema for DeliveryFlow - UPDATED WITH CATEGORY
CREATE DATABASE IF NOT EXISTS delivery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE delivery_db;

-- Bảng users
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('customer', 'shipper', 'admin') NOT NULL,
  phone VARCHAR(20),
  fcm_token VARCHAR(255),
  is_online TINYINT(1) DEFAULT 0,
  last_online TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role),
  INDEX idx_online (is_online)
) ENGINE=InnoDB;

-- Bảng orders - ✅ UPDATED: Added category column
CREATE TABLE IF NOT EXISTS orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  shipper_id INT,
  pickup_lat DECIMAL(10, 8) NOT NULL,
  pickup_lng DECIMAL(11, 8) NOT NULL,
  pickup_address TEXT NOT NULL,
  delivery_lat DECIMAL(10, 8) NOT NULL,
  delivery_lng DECIMAL(11, 8) NOT NULL,
  delivery_address TEXT NOT NULL,
  -- ✅ NEW: Order category
  category ENUM(
    'regular',      -- Hàng thường (default)
    'food',         -- Đồ ăn/Thức uống
    'frozen',       -- Đồ đông lạnh
    'valuable',     -- Hàng giá trị cao
    'electronics',  -- Linh kiện điện tử
    'fashion',      -- Thời trang
    'documents',    -- Sách/Tài liệu
    'fragile',      -- Đồ dễ vỡ
    'medical',      -- Y tế/Dược phẩm
    'gift'          -- Quà tặng
  ) DEFAULT 'regular' NOT NULL,
  status ENUM('pending', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled') DEFAULT 'pending',
  -- Pricing fields
  distance_km DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(10, 2) DEFAULT 0,
  shipper_amount DECIMAL(10, 2) DEFAULT 0,
  app_commission DECIMAL(10, 2) DEFAULT 0,
  proof_image_base64 LONGTEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (shipper_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_status (status),
  INDEX idx_category (category),
  INDEX idx_customer (customer_id),
  INDEX idx_shipper (shipper_id)
) ENGINE=InnoDB;

-- Bảng locations
CREATE TABLE IF NOT EXISTS locations (
  id INT PRIMARY KEY AUTO_INCREMENT,
  shipper_id INT NOT NULL,
  order_id INT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  accuracy FLOAT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (shipper_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
  INDEX idx_shipper (shipper_id),
  INDEX idx_order (order_id)
) ENGINE=InnoDB;

-- Bảng order_history
CREATE TABLE IF NOT EXISTS order_history (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  shipper_id INT NULL,
  status VARCHAR(50) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (shipper_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_order (order_id)
) ENGINE=InnoDB;

-- Thêm tài khoản Admin mẫu (mật khẩu: 'admin123')
INSERT IGNORE INTO users (id, name, email, password, role, phone) VALUES
(1, 'Admin Full Control', 'admin@example.com', '$2a$10$w4es.9.p.d87A45Vf32.a.7hX.4IqfvyX51sJ3DP2A8/8p7n.1u.S', 'admin', '0987654321');