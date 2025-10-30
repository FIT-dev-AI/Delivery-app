// frontend/lib/data/services/image_picker_service.dart (PHIÊN BẢN NÂNG CẤP)

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import để dùng debugPrint
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Opens the camera to take a picture, compresses it, and returns a Base64 string.
  Future<String?> pickImageFromCamera() async {
    // 1. Kiểm tra và yêu cầu quyền truy cập Camera
    var status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          maxWidth: 1080,
        );
        // 2. Tái sử dụng hàm xử lý ảnh
        return _processImage(image);
      } catch (e) {
        // 3. Thay thế print() bằng debugPrint()
        debugPrint('Lỗi khi chụp ảnh: $e');
        return null;
      }
    } else {
      debugPrint('Không được cấp quyền truy cập camera.');
      return null;
    }
  }

  /// Opens the gallery to select a picture, compresses it, and returns a Base64 string.
  Future<String?> pickImageFromGallery() async {
    // 1. Kiểm tra và yêu cầu quyền truy cập Thư viện ảnh
    var status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
       try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1080,
        );
        // 2. Tái sử dụng hàm xử lý ảnh
        return _processImage(image);
      } catch (e) {
        // 3. Thay thế print() bằng debugPrint()
        debugPrint('Lỗi khi chọn ảnh từ thư viện: $e');
        return null;
      }
    } else {
       debugPrint('Không được cấp quyền truy cập thư viện ảnh.');
       return null;
    }
  }

  /// Hàm xử lý ảnh chung để tránh lặp code (DRY Principle)
  Future<String?> _processImage(XFile? image) async {
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      return base64Encode(bytes); // Chuyển thành Base64
    }
    return null;
  }
}