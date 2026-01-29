import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();
  static const _deviceIdKey = 'device_id';
  
  String? _deviceId;

  /// Get the current device ID. Initializes it if not present.
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    // Try to read from storage
    String? storedId = await _storage.read(key: _deviceIdKey);

    if (storedId == null) {
      // Generate new ID if none exists
      storedId = _uuid.v4();
      await _storage.write(key: _deviceIdKey, value: storedId);
    }

    _deviceId = storedId;
    return _deviceId!;
  }

  /// Get the cached device ID (synchronous). 
  /// Warning: Call getDeviceId() at least once before using this.
  String get currentDeviceId {
    if (_deviceId == null) {
      throw Exception("Device ID not initialized. Call getDeviceId() first.");
    }
    return _deviceId!;
  }

  static const _genderKey = 'user_gender';

  Future<void> saveGender(String gender) async {
    await _storage.write(key: _genderKey, value: gender);
  }

  Future<String?> getGender() async {
    return await _storage.read(key: _genderKey);
  }
}
