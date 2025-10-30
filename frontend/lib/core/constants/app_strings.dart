// lib/core/constants/app_strings.dart
// ✅ UPDATED: Added category labels

class AppStrings {
  // App
  static const String appName = 'Delivery App';

  // Auth
  static const String login = 'Đăng Nhập';
  static const String register = 'Đăng Ký';
  static const String email = 'Email';
  static const String password = 'Mật Khẩu';
  static const String name = 'Họ và Tên';
  static const String phone = 'Số Điện Thoại';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String dontHaveAccount = 'Chưa có tài khoản?';
  static const String alreadyHaveAccount = 'Đã có tài khoản?';

  // Roles
  static const String customer = 'Khách Hàng';
  static const String shipper = 'Tài Xế';
  static const String selectRole = 'Chọn vai trò';

  // Orders
  static const String myOrders = 'Đơn Hàng Của Tôi';
  static const String orderDetails = 'Chi Tiết Đơn Hàng';
  static const String createOrder = 'Tạo Đơn Hàng';
  static const String pickupLocation = 'Điểm Lấy Hàng';
  static const String deliveryLocation = 'Điểm Giao Hàng';

  // ✅ NEW: Order Categories
  static const String orderCategory = 'Loại Hàng';
  static const String selectCategory = 'Chọn loại hàng';
  static const String categoryRequired = 'Vui lòng chọn loại hàng';
  
  // Category Names (Vietnamese)
  static const String categoryRegular = 'Hàng thường';
  static const String categoryFood = 'Đồ ăn/Thức uống';
  static const String categoryFrozen = 'Đồ đông lạnh';
  static const String categoryValuable = 'Hàng giá trị cao';
  static const String categoryElectronics = 'Linh kiện điện tử';
  static const String categoryFashion = 'Thời trang';
  static const String categoryDocuments = 'Sách/Tài liệu';
  static const String categoryFragile = 'Đồ dễ vỡ';
  static const String categoryMedical = 'Y tế/Dược phẩm';
  static const String categoryGift = 'Quà tặng';

  // Category Descriptions
  static const String categoryRegularDesc = 'Hàng hóa thông thường, không đặc biệt';
  static const String categoryFoodDesc = 'Thực phẩm, đồ ăn nhanh, đồ uống';
  static const String categoryFrozenDesc = 'Thực phẩm đông lạnh, cần bảo quản lạnh';
  static const String categoryValuableDesc = 'Trang sức, điện tử đắt tiền, cần cẩn thận';
  static const String categoryElectronicsDesc = 'Linh kiện máy tính, phụ kiện điện tử';
  static const String categoryFashionDesc = 'Quần áo, giày dép, phụ kiện thời trang';
  static const String categoryDocumentsDesc = 'Sách vở, giấy tờ, tài liệu quan trọng';
  static const String categoryFragileDesc = 'Đồ thủy tinh, gốm sứ, cần xử lý cẩn thận';
  static const String categoryMedicalDesc = 'Thuốc men, thiết bị y tế, dược phẩm';
  static const String categoryGiftDesc = 'Quà sinh nhật, quà kỷ niệm, quà tặng';

  // Status
  static const String pending = 'Chờ Xử Lý';
  static const String assigned = 'Đã Phân Công';
  static const String pickedUp = 'Đã Lấy Hàng';
  static const String inTransit = 'Đang Giao';
  static const String delivered = 'Đã Giao';
  static const String cancelled = 'Đã Hủy';

  // Actions
  static const String accept = 'Nhận Đơn';
  static const String reject = 'Từ Chối';
  static const String startDelivery = 'Bắt Đầu Giao';
  static const String completeDelivery = 'Hoàn Thành';
  static const String uploadProof = 'Chụp Ảnh Xác Nhận';
  static const String call = 'Gọi Điện';

  // Messages
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String loginFailed = 'Đăng nhập thất bại';
  static const String noOrders = 'Chưa có đơn hàng nào';
  static const String loading = 'Đang tải...';
  static const String error = 'Có lỗi xảy ra';
}