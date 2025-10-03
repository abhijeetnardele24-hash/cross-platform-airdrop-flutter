import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

    // Background services disabled for simplified build
    // TODO: Re-enable when workmanager and background_fetch are available
    debugPrint('Background services initialized (simplified mode)');

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

      // Background task scheduling disabled for simplified build
      debugPrint('Background transfer scheduled for: $transferId');
    } catch (e) {
      debugPrint('Error starting background transfer: $e');
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
        debugPrint('Error updating progress: $e');
        timer.cancel();
      }
    });
  }

  Future<void> stopBackgroundTransfer(String transferId) async {
    _progressTimer?.cancel();
    
    // Background task cancellation disabled for simplified build
    debugPrint('Background transfer stopped for: $transferId');
    
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

  // Background callbacks removed for simplified build
  void dispose() {
    _progressTimer?.cancel();
    _isInitialized = false;
  }
}
