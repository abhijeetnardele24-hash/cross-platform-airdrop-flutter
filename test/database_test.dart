import 'package:flutter_test/flutter_test.dart';
import 'package:cross_platform_airdrop/services/database_service.dart';
import 'package:cross_platform_airdrop/models/trusted_device.dart';
import 'package:cross_platform_airdrop/models/transfer_model.dart';
import 'package:cross_platform_airdrop/models/device_model.dart';
import 'dart:typed_data';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  group('DatabaseService Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      dbService = DatabaseService();
      // Database is initialized lazily via database getter
    });

    tearDown(() async {
      await dbService.close();
    });

    test('Add and retrieve trusted device', () async {
      final device = TrustedDevice(
        id: 'test-device-1',
        name: 'Test Device',
        avatar: 'avatar.png',
        fingerprint: 'fingerprint123',
        isApproved: true,
        trustLevel: 1,
        addedAt: DateTime.now(),
        lastConnected: DateTime.now(),
      );

      await dbService.saveTrustedDevice(device);
      final devices = await dbService.getTrustedDevices();

      expect(devices.length, equals(1));
      expect(devices.first.id, equals(device.id));
      expect(devices.first.name, equals(device.name));
    });

    test('Add and retrieve transfer history', () async {
      final fromDevice = DeviceModel(
        id: 'device1',
        name: 'Device 1',
        ipAddress: '192.168.1.1',
        type: DeviceType.android,
        lastSeen: DateTime.now(),
      );

      final toDevice = DeviceModel(
        id: 'device2',
        name: 'Device 2',
        ipAddress: '192.168.1.2',
        type: DeviceType.ios,
        lastSeen: DateTime.now(),
      );

      final transfer = TransferModel(
        id: 'transfer1',
        fileName: 'test.txt',
        filePath: '/path/test.txt',
        fileSize: 1024,
        mimeType: 'text/plain',
        fromDevice: fromDevice,
        toDevice: toDevice,
        status: TransferStatus.completed,
        direction: TransferDirection.send,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(seconds: 5)),
        bytesTransferred: 1024,
        progress: 1.0,
        checksum: 'checksum123',
        isEncrypted: true,
      );

      await dbService.saveTransfer(transfer);
      final history = await dbService.getTransferHistory();

      expect(history.length, equals(1));
      expect(history.first.id, equals(transfer.id));
      expect(history.first.checksum, equals(transfer.checksum));
      expect(history.first.isEncrypted, equals(true));
    });

    test('Secure delete all', () async {
      // Add some data first
      final device = TrustedDevice(
        id: 'test-device-2',
        name: 'Test Device 2',
        avatar: 'avatar.png',
        fingerprint: 'fingerprint456',
        isApproved: true,
        trustLevel: 1,
        addedAt: DateTime.now(),
        lastConnected: DateTime.now(),
      );

      await dbService.saveTrustedDevice(device);
      await dbService.secureDeleteAll();

      final devices = await dbService.getTrustedDevices();
      expect(devices.length, equals(0));
    });
  });
}
