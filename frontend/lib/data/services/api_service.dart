import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Interceptor để thêm token và log
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Thêm token vào header
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // ✅ IMPROVED LOGGING: Full URL for debugging
        final fullUrl = '${options.baseUrl}${options.path}';
        debugPrint('📤 REQUEST: ${options.method} $fullUrl');
        if (options.data != null) {
          debugPrint('📤 DATA: ${options.data}');
        }
        if (options.queryParameters.isNotEmpty) {
          debugPrint('📤 QUERY: ${options.queryParameters}');
        }
        
        return handler.next(options);
      },
      
      onResponse: (response, handler) {
        final fullUrl = '${response.requestOptions.baseUrl}${response.requestOptions.path}';
        debugPrint('📥 RESPONSE: ${response.statusCode} $fullUrl');
        return handler.next(response);
      },
      
      onError: (error, handler) async {
        final fullUrl = '${error.requestOptions.baseUrl}${error.requestOptions.path}';
        debugPrint('❌ ERROR: ${error.response?.statusCode} $fullUrl');
        debugPrint('❌ ERROR MESSAGE: ${error.message}');
        if (error.response?.data != null) {
          debugPrint('❌ ERROR DATA: ${error.response?.data}');
        }
        
        // Nếu 401, xóa token (hết hạn)
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'token');
        }
        
        return handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
