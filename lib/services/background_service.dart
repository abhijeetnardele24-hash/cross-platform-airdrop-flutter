import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart' as wm;
import 'package:background_fetch/background_fetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_transfer_service.dart';
import 'notification_service.dart';
import '../models/transfer_model.dart';

class BackgroundService {
  static const String transferTaskName = 'transferBackgroundTask';
  static const String notificationChannelId = 'transfer_channel';
  static const String notificationChannelName = 'File Transfers';

  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FileTransferService _transferService = FileTransferService();
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  Timer? _progressTimer;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize notifications
    await _notificationService.initialize();

    // Initialize WorkManager for Android
    if (Platform.isAndroid) {
      await wm.Workmanager()
          .initialize(callbackDispatcher, isInDebugMode: true);
    }

    // Initialize Background Fetch for iOS
    if (Platform.isIOS) {
      await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.ANY,
        ),
        _backgroundFetchCallback,
        _backgroundFetchTimeout,
      );
    }

    _isInitialized = true;
  }

  Future<void> startBackgroundTransfer(String transferId) async {
    try {
      final transfers = _transferService.getActiveTransfers();
      final transfer = transfers.cast<TransferModel?>().firstWhere(
            (t) => t?.id == transferId,
            orElse: () => null,
          );

      if (transfer == null) return;

      // Show initial notification
      await _showTransferNotification(transfer);

      // Start progress updates
      _startProgressUpdates(transferId);

      // Schedule background task
      if (Platform.isAndroid) {
        await wm.Workmanager().registerOneOffTask(
          transferId,
          transferTaskName,
          inputData: {'transferId': transferId},
          constraints: wm.Constraints(
            networkType: wm.NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
      } else if (Platform.isIOS) {
        await BackgroundFetch.start().then((_) {
          // Background fetch will handle the transfer
          _processTransferInBackground(transferId);
        });
      }
    } catch (e) {
      print('Error starting background transfer: $e');
    }
  }

  Future<void> _showTransferNotification(TransferModel transfer) async {
    await _notificationService.showTransferNotification(
      transfer.id,
      'Transferring ${transfer.fileName}',
      'Starting transfer...',
      transfer.progress,
    );
  }

  void _startProgressUpdates(String transferId) {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final transfers = _transferService.getActiveTransfers();
        final transfer = transfers.cast<TransferModel?>().firstWhere(
              (t) => t?.id == transferId,
              orElse: () => null,
            );

        if (transfer == null) {
          timer.cancel();
          return;
        }

        final progress = transfer.progress;
        final status = transfer.status;

        String title;
        String body;

        switch (status) {
          case TransferStatus.transferring:
            title = 'Transferring ${transfer.fileName}';
            body = '${(progress * 100).round()}% complete';
            break;
          case TransferStatus.completed:
            title = 'Transfer Complete';
            body = '${transfer.fileName} has been transferred successfully';
            timer.cancel();
            break;
          case TransferStatus.failed:
            title = 'Transfer Failed';
            body = 'Failed to transfer ${transfer.fileName}';
            timer.cancel();
            break;
          default:
            title = 'Transfer Status';
            body = 'Processing ${transfer.fileName}';
        }

        await _notificationService.showTransferNotification(
          transferId,
          title,
          body,
          progress,
        );
      } catch (e) {
        print('Error updating progress: $e');
        timer.cancel();
      }
    });
  }

  Future<void> _processTransferInBackground(String transferId) async {
    try {
      // Get transfer details from persistent storage
      final prefs = await SharedPreferences.getInstance();
      final transferData = prefs.getString('transfer_$transferId');

      if (transferData != null) {
        // Resume or continue transfer
        // This would integrate with your existing transfer logic
        await _transferService.resumeTransfer(transferId);
      }
    } catch (e) {
      print('Background transfer failed: $e');
    }
  }

  Future<void> stopBackgroundTransfer(String transferId) async {
    _progressTimer?.cancel();

    if (Platform.isAndroid) {
      await wm.Workmanager().cancelByUniqueName(transferId);
    } else if (Platform.isIOS) {
      await BackgroundFetch.stop();
    }

    await _notificationService.cancelNotification(transferId.hashCode);
  }

  Future<void> saveTransferState(
      String transferId, Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transfer_$transferId', state.toString());
  }

  Future<Map<String, dynamic>?> loadTransferState(String transferId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('transfer_$transferId');
    return data != null ? {'data': data} : null;
  }

  void _backgroundFetchCallback(String taskId) async {
    print("[BackgroundFetch] Event received: $taskId");

    // Process any pending transfers
    final activeTransfers = _transferService.getActiveTransfers();
    for (final transfer in activeTransfers) {
      if (transfer.status == TransferStatus.transferring) {
        await _processTransferInBackground(transfer.id);
      }
    }

    BackgroundFetch.finish(taskId);
  }

  void _backgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }
}

// WorkManager callback dispatcher for Android
@pragma('vm:entry-point')
void callbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
    final transferId = inputData?['transferId'] as String?;

    if (transferId != null) {
      final backgroundService = BackgroundService();
      await backgroundService.initialize();
      await backgroundService._processTransferInBackground(transferId);
    }

    return Future.value(true);
  });
}
