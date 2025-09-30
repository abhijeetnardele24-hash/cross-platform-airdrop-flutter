import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'dart:async';
import 'package:cross_platform_airdrop/services/file_transfer_service.dart';
import 'package:cross_platform_airdrop/models/transfer_model.dart';
import 'package:cross_platform_airdrop/models/device_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileTransferService Basic Tests', () {
    late FileTransferService transferService;
    late DeviceModel testDevice;
    late String testFilePath;

    setUp(() async {
      transferService = FileTransferService();

      testDevice = DeviceModel(
        id: 'test-device',
        name: 'Test Device',
        ipAddress: '192.168.1.100',
        type: DeviceType.android,
        lastSeen: DateTime.now(),
      );

      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      testFilePath = '${tempDir.path}/test_file.txt';
      final testFile = File(testFilePath);
      await testFile.writeAsString('This is a test file for transfer testing.');
    });

    tearDown(() async {
      await transferService.close();
      // Clean up test file with retry logic
      final testFile = File(testFilePath);
      if (await testFile.exists()) {
        try {
          await testFile.delete();
        } catch (e) {
          // File might be locked, try again after a delay
          await Future.delayed(const Duration(milliseconds: 100));
          try {
            await testFile.delete();
          } catch (e2) {
            // Ignore cleanup errors in tests
            print('Warning: Could not clean up test file: $e2');
          }
        }
      }
    });

    test('Bandwidth throttling settings', () {
      // Test bandwidth limit setting
      transferService.setBandwidthLimit(102400); // 100 KB/s
      // Method should execute without error

      // Test unlimited
      transferService.setBandwidthLimit(0);
    });

    test('Concurrent transfer limits', () {
      // Test max concurrent transfers setting
      transferService.setMaxConcurrentTransfers(5);
      // Method should execute without error
    });

    test('Invalid file path handling', () async {
      // Test with non-existent file
      final invalidPath = '/non/existent/file.txt';

      try {
        await transferService.queueFileTransfer(invalidPath, testDevice);
        fail('Should have thrown exception for invalid file');
      } catch (e) {
        expect(e.toString(), contains('File does not exist'));
      }
    });

    test('Service initialization and cleanup', () async {
      // Test that service can be initialized and closed
      expect(transferService.connectionState, isNotNull);

      await transferService.close();
      // Should not throw
    });

    test('Error message display for different error types', () {
      // Test that error messages are properly formatted
      expect(TransferError.networkError.displayMessage,
          contains('Network connection lost'));
      expect(TransferError.deviceDisconnected.displayMessage,
          contains('Device disconnected'));
      expect(TransferError.timeout.displayMessage, contains('timed out'));
      expect(TransferError.fileNotFound.displayMessage,
          contains('File not found'));
      expect(TransferError.unknown.displayMessage, contains('unknown error'));
    });

    test('Error retryability', () {
      // Test which errors are retryable
      expect(TransferError.networkError.isRetryable, isTrue);
      expect(TransferError.deviceDisconnected.isRetryable, isTrue);
      expect(TransferError.timeout.isRetryable, isTrue);
      expect(TransferError.encryptionError.isRetryable, isTrue);

      expect(TransferError.fileNotFound.isRetryable, isFalse);
      expect(TransferError.permissionDenied.isRetryable, isFalse);
      expect(TransferError.storageFull.isRetryable, isFalse);
    });

    test('Transfer model properties', () {
      final transfer = TransferModel(
        id: 'test-id',
        fileName: 'test.txt',
        filePath: '/path/test.txt',
        fileSize: 1024,
        mimeType: 'text/plain',
        fromDevice: DeviceModel(
            id: 'from',
            name: 'From Device',
            ipAddress: '1.1.1.1',
            type: DeviceType.android,
            lastSeen: DateTime.now()),
        toDevice: testDevice,
        status: TransferStatus.pending,
        direction: TransferDirection.send,
        startTime: DateTime.now(),
      );

      expect(transfer.formattedFileSize, equals('1.00 KB'));
      expect(transfer.progress, equals(0.0));
      expect(transfer.isPaused, isFalse);
    });
  });
}
