import '../models/trusted_device.dart';
import 'database_service.dart';

class TrustedDeviceService {
  final DatabaseService _db = DatabaseService();

  Future<List<TrustedDevice>> getTrustedDevices() async {
    return await _db.getTrustedDevices();
  }

  Future<void> addTrustedDevice(TrustedDevice device) async {
    await _db.saveTrustedDevice(device);
  }

  Future<void> removeTrustedDevice(String id) async {
    await _db.deleteTrustedDevice(id);
  }

  Future<TrustedDevice?> getTrustedDevice(String id) async {
    return await _db.getTrustedDevice(id);
  }

  Future<void> updateTrustedDevice(TrustedDevice device) async {
    await _db.saveTrustedDevice(device);
  }
}
