import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:cross_platform_airdrop/services/file_transfer_service.dart';
import 'package:cross_platform_airdrop/models/transfer_model.dart';
import 'package:cross_platform_airdrop/models/device_model.dart';
import 'package:cross_platform_airdrop/utils/encryption_utils.dart';

// Dummy stubs for missing variables
bool _isInitialized = true;
String _sessionCode = 'dummy-session';
var _encryptionKey = null; // Replace with actual key if needed

// Create a testable version of FileTransferService that allows testing without network
class TestableFileTransferService extends FileTransferService {
  // Override to skip initialization that requires network
  @override
  Future<void> initialize(String sessionCode, {bool isHost = true}) async {
    _isInitialized = true;
    _sessionCode = sessionCode;
    _encryptionKey =
        EncryptionUtils.deriveAESKey(Uint8List(32)); // dummy key for testing
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileTransferService Error Scenarios Tests', () {
    late TestableFileTransferService transferService;
    late DeviceModel testDevice;
    late String testFilePath;

    setUp(() async {
      transferService = TestableFileTransferService();
      await transferService.initialize('test-session');

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

    test('Transfer queue functionality', () async {
      // Test queuing multiple transfers
      final transferIds = <String>[];

      for (int i = 0; i < 3; i++) {
        final id = await transferService.queueFileTransfer(
          testFilePath,
          testDevice,
        );
        transferIds.add(id);
      }

      expect(transferService.getTransferQueue().length, equals(3));
      expect(transferIds.length, equals(3));
    });

    test('Bandwidth throttling settings', () {
      // Test bandwidth limit setting
      transferService.setBandwidthLimit(102400); // 100 KB/s
      // Note: We can't directly test private field, but method should work

      // Test unlimited
      transferService.setBandwidthLimit(0);
    });

    test('Concurrent transfer limits', () {
      // Test max concurrent transfers setting
      transferService.setMaxConcurrentTransfers(5);
      // Method should execute without error
    });

    test('Pause and resume functionality', () async {
      // Queue a transfer
      final transferId = await transferService.queueFileTransfer(
        testFilePath,
        testDevice,
      );

      // Should be able to pause (even if not active, should handle gracefully)
      await transferService.pauseTransfer(transferId);

      // Should be able to resume
      await transferService.resumeTransfer(transferId);
    });

    test('Transfer cancellation', () async {
      // Queue a transfer
      final transferId = await transferService.queueFileTransfer(
        testFilePath,
        testDevice,
      );

      // Cancel it
      await transferService.cancelTransfer(transferId);

      // Should be removed from queue
      final queue = transferService.getTransferQueue();
      expect(queue.where((t) => t.id == transferId).isEmpty, isTrue);
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

    test('Transfer status transitions', () async {
      // Queue a transfer
      final transferId = await transferService.queueFileTransfer(
        testFilePath,
        testDevice,
      );

      final queue = transferService.getTransferQueue();
      final transfer = queue.firstWhere((t) => t.id == transferId);

      expect(transfer.status, equals(TransferStatus.pending));
      expect(transfer.direction, equals(TransferDirection.send));
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
