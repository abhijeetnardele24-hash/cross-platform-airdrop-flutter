import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_transfer_service.dart';

class ShareService {
  static const String _channelName = 'com.crossplatformairdrop.share';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal() {
    _setupMethodChannel();
  }

  final FileTransferService _transferService = FileTransferService();
  final StreamController<List<String>> _sharedFilesController =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get sharedFilesStream => _sharedFilesController.stream;

  void _setupMethodChannel() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'sharedFilesReceived':
        final List<dynamic> files = call.arguments as List<dynamic>;
        final filePaths = files.map((file) => file.toString()).toList();
        _sharedFilesController.add(filePaths);
        await _processSharedFiles(filePaths);
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _processSharedFiles(List<String> filePaths) async {
    try {
      for (final filePath in filePaths) {
        if (filePath.startsWith('text:')) {
          // Handle shared text
          final text = filePath.substring(5);
          await _handleSharedText(text);
        } else {
          // Handle shared file
          await _handleSharedFile(filePath);
        }
      }
    } catch (e) {
      print('Error processing shared files: $e');
    }
  }

  Future<void> _handleSharedText(String text) async {
    try {
      // Save text to a temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'shared_text_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsString(text);

      // Create a transfer for the text file
      // This would integrate with your device selection UI
      print('Shared text saved to: ${file.path}');
    } catch (e) {
      print('Error handling shared text: $e');
    }
  }

  Future<void> _handleSharedFile(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        // Create a transfer for the shared file
        // This would integrate with your device selection UI
        print('Shared file ready: ${file.path}');
      } else {
        print('Shared file does not exist: $filePath');
      }
    } catch (e) {
      print('Error handling shared file: $e');
    }
  }

  Future<List<String>> getPendingSharedFiles() async {
    try {
      final result = await _channel.invokeMethod('getSharedFiles');
      return List<String>.from(result ?? []);
    } catch (e) {
      print('Error getting shared files: $e');
      return [];
    }
  }

  Future<void> clearSharedFiles() async {
    try {
      await _channel.invokeMethod('clearSharedFiles');
    } catch (e) {
      print('Error clearing shared files: $e');
    }
  }

  Future<void> saveSharedFileInfo(
      String filePath, Map<String, dynamic> info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shared_file_$filePath', info.toString());
  }

  Future<Map<String, dynamic>?> getSharedFileInfo(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('shared_file_$filePath');
    return data != null ? {'data': data} : null;
  }

  void dispose() {
    _sharedFilesController.close();
  }
}
