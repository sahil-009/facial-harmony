import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_service.dart';

class ApiService {
  // Use 10.0.2.2 for Android simulator, localhost for iOS/Web
  // Or your machine's local IP for physical devices
  static const String baseUrl = 'http://10.0.2.2:8000'; 

  Future<bool> verifyPurchase({
    required String deviceId,
    required String token,
    required String productId,
    String packageName = 'com.facialharmony.app',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/purchase/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'purchase_token': token,
          'product_id': productId,
          'package_name': packageName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      print('Purchase verification error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> analyzeFace({
    required String imageBase64,
    required String gender,
  }) async {
    final deviceId = await DeviceService().getDeviceId();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze/face'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': deviceId,
          'image': imageBase64,
          'gender': gender,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Analysis failed');
      }
    } catch (e) {
      print('Face analysis error: $e');
      rethrow;
    }
  }
}
