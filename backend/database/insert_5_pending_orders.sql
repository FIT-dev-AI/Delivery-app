-- ============================================
-- INSERT 5 PENDING ORDERS IN HCM
-- Với cân nặng: 1kg, 5kg, 10kg, 20kg, 30kg
-- Và category khác nhau
-- Địa chỉ đã được rút ngắn để tối ưu UI
-- ============================================

-- ✅ Đơn hàng 1: FOOD - 1kg - Quận 1 → Quận 3 (khoảng cách ~3.5km)
INSERT INTO orders (
    customer_id,
    shipper_id,
    pickup_lat,
    pickup_lng,
    pickup_address,
    delivery_lat,
    delivery_lng,
    delivery_address,
    status,
    category,
    weight,
    distance_km,
    total_amount,
    shipper_amount,
    app_commission,
    notes,
    proof_image_base64,
    created_at,
    updated_at
) VALUES (
    1, -- ✅ Thay bằng customer_id thực tế trong database
    NULL, -- ✅ Pending nên shipper_id = NULL
    10.7769,  -- Điểm lấy: Quận 1 (Nguyễn Huệ)
    106.7009,
    '123 Nguyễn Huệ, Q.1, TP.HCM',
    10.7833,  -- Điểm giao: Quận 3
    106.6833,
    '456 CMT8, Q.3, TP.HCM',
    'pending',
    'food',
    1.0,      -- ✅ 1kg
    3.50,
    0.00,     -- ✅ Pending nên chưa tính tiền
    0.00,
    0.00,
    'Đồ ăn nhanh, cần giao trong 30 phút',
    NULL,
    NOW(),
    NOW()
);

-- ✅ Đơn hàng 2: REGULAR - 5kg - Quận 7 → Quận 1 (khoảng cách ~6.0km)
INSERT INTO orders (
    customer_id,
    shipper_id,
    pickup_lat,
    pickup_lng,
    pickup_address,
    delivery_lat,
    delivery_lng,
    delivery_address,
    status,
    category,
    weight,
    distance_km,
    total_amount,
    shipper_amount,
    app_commission,
    notes,
    proof_image_base64,
    created_at,
    updated_at
) VALUES (
    1, -- ✅ Thay bằng customer_id thực tế
    NULL,
    10.7290,  -- Điểm lấy: Quận 7
    106.7090,
    '789 Nguyễn Lương Bằng, Q.7, TP.HCM',
    10.7769,  -- Điểm giao: Quận 1
    106.7009,
    '101 Lê Lợi, Q.1, TP.HCM',
    'pending',
    'regular',
    5.0,      -- ✅ 5kg
    6.00,
    0.00,
    0.00,
    0.00,
    'Hàng thường, giao trong giờ hành chính',
    NULL,
    NOW(),
    NOW()
);

-- ✅ Đơn hàng 3: ELECTRONICS - 10kg - Bình Thạnh → Tân Bình (khoảng cách ~7.5km)
INSERT INTO orders (
    customer_id,
    shipper_id,
    pickup_lat,
    pickup_lng,
    pickup_address,
    delivery_lat,
    delivery_lng,
    delivery_address,
    status,
    category,
    weight,
    distance_km,
    total_amount,
    shipper_amount,
    app_commission,
    notes,
    proof_image_base64,
    created_at,
    updated_at
) VALUES (
    1, -- ✅ Thay bằng customer_id thực tế
    NULL,
    10.8050,  -- Điểm lấy: Bình Thạnh
    106.7100,
    '200 Điện Biên Phủ, Q.Bình Thạnh, TP.HCM',
    10.8000,  -- Điểm giao: Tân Bình
    106.6500,
    '300 Cộng Hòa, Q.Tân Bình, TP.HCM',
    'pending',
    'electronics',
    10.0,     -- ✅ 10kg
    7.50,
    0.00,
    0.00,
    0.00,
    'Linh kiện điện tử, cần cẩn thận, tránh va đập',
    NULL,
    NOW(),
    NOW()
);

-- ✅ Đơn hàng 4: FASHION - 20kg - Quận 3 → Quận 7 (khoảng cách ~8.2km)
INSERT INTO orders (
    customer_id,
    shipper_id,
    pickup_lat,
    pickup_lng,
    pickup_address,
    delivery_lat,
    delivery_lng,
    delivery_address,
    status,
    category,
    weight,
    distance_km,
    total_amount,
    shipper_amount,
    app_commission,
    notes,
    proof_image_base64,
    created_at,
    updated_at
) VALUES (
    1, -- ✅ Thay bằng customer_id thực tế
    NULL,
    10.7833,  -- Điểm lấy: Quận 3
    106.6833,
    '500 Võ Văn Tần, Q.3, TP.HCM',
    10.7290,  -- Điểm giao: Quận 7
    106.7090,
    '600 Nguyễn Thị Thập, Q.7, TP.HCM',
    'pending',
    'fashion',
    20.0,     -- ✅ 20kg
    8.20,
    0.00,
    0.00,
    0.00,
    'Quần áo, gói lớn, tránh ướt mưa',
    NULL,
    NOW(),
    NOW()
);

-- ✅ Đơn hàng 5: VALUABLE - 30kg - Quận 1 → Bình Thạnh (khoảng cách ~4.8km)
INSERT INTO orders (
    customer_id,
    shipper_id,
    pickup_lat,
    pickup_lng,
    pickup_address,
    delivery_lat,
    delivery_lng,
    delivery_address,
    status,
    category,
    weight,
    distance_km,
    total_amount,
    shipper_amount,
    app_commission,
    notes,
    proof_image_base64,
    created_at,
    updated_at
) VALUES (
    1, -- ✅ Thay bằng customer_id thực tế
    NULL,
    10.7769,  -- Điểm lấy: Quận 1
    106.7009,
    '700 Đông Khởi, Q.1, TP.HCM',
    10.8050,  -- Điểm giao: Bình Thạnh
    106.7100,
    '800 Xô Viết Nghệ Tĩnh, Q.Bình Thạnh, TP.HCM',
    'pending',
    'valuable',
    30.0,     -- ✅ 30kg
    4.80,
    0.00,
    0.00,
    0.00,
    'Hàng giá trị cao, yêu cầu giao an toàn, ký nhận',
    NULL,
    NOW(),
    NOW()
);

-- ============================================
-- LƯU Ý:
-- 1. Thay customer_id = 1 bằng customer_id thực tế trong bảng users
-- 2. Các đơn hàng này sẽ ở trạng thái 'pending' và chờ shipper nhận
-- 3. total_amount, shipper_amount, app_commission = 0.00 vì chưa tính giá
-- 4. proof_image_base64 = NULL vì chưa có shipper nhận đơn
-- 5. created_at và updated_at sẽ tự động được set bởi database
-- ============================================

