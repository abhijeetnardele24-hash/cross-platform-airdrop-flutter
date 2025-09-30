import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/cloud_relay_service.dart';

class CloudFallbackDialog extends StatefulWidget {
  final File file;
  final void Function(String url) onComplete;
  const CloudFallbackDialog({super.key, required this.file, required this.onComplete});

  @override
  State<CloudFallbackDialog> createState() => _CloudFallbackDialogState();
}

class _CloudFallbackDialogState extends State<CloudFallbackDialog> {
  double _progress = 0.0;
  String? _downloadUrl;
  String? _error;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    setState(() { _uploading = true; });
    try {
      final url = await CloudRelayService().uploadFile(
        widget.file,
        onProgress: (p) => setState(() => _progress = p),
      );
      setState(() {
        _downloadUrl = url;
        _uploading = false;
      });
      widget.onComplete(url);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cloud Relay Fallback'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_uploading) ...[
            const Text('Uploading to cloud...'),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _progress),
          ] else if (_downloadUrl != null) ...[
            const Icon(Icons.cloud_done, color: Colors.green, size: 32),
            const SizedBox(height: 12),
            SelectableText('Download Link:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(_downloadUrl!, style: TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy Link'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _downloadUrl!));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!')));
              },
            ),
          ] else if (_error != null) ...[
            Icon(Icons.error, color: Colors.red[400], size: 32),
            const SizedBox(height: 12),
            Text('Upload failed: $_error', style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        if (!_uploading) TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
