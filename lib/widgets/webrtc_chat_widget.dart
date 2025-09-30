import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/webrtc_provider.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/file_utils.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class WebRTCChatWidget extends StatefulWidget {
  final String roomCode;
  final String signalingUrl;
  const WebRTCChatWidget({super.key, required this.roomCode, required this.signalingUrl});

  @override
  State<WebRTCChatWidget> createState() => _WebRTCChatWidgetState();
}

class _WebRTCChatWidgetState extends State<WebRTCChatWidget> {
  IconData _fileTypeIcon(String fileName) {
    final ext = fileName.toLowerCase();
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.gif') || ext.endsWith('.bmp') || ext.endsWith('.webp')) {
      return Icons.image;
    } else if (ext.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi')) {
      return Icons.movie;
    } else if (ext.endsWith('.mp3') || ext.endsWith('.wav')) {
      return Icons.music_note;
    } else if (ext.endsWith('.zip') || ext.endsWith('.rar')) {
      return Icons.archive;
    } else if (ext.endsWith('.txt')) {
      return Icons.text_snippet;
    } else if (ext.endsWith('.doc') || ext.endsWith('.docx')) {
      return Icons.description;
    } else {
      return Icons.insert_drive_file;
    }
  }

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WebRTCProvider(roomCode: widget.roomCode, signalingUrl: widget.signalingUrl)..start(isCaller: true),
      child: Consumer<WebRTCProvider>(
        builder: (context, webrtc, _) {
          return SizedBox(
            height: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(webrtc.connected ? Icons.link : Icons.link_off, color: webrtc.connected ? Colors.green : Colors.red),
                    const SizedBox(width: 8),
                    Text(webrtc.connected ? 'Connected (WebRTC)' : 'Connecting...'),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          reverse: true,
                          children: [
                            ...webrtc.chatMessages.reversed.map((msg) => Align(
                              alignment: msg.startsWith('Me:') ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: msg.startsWith('Me:') ? Colors.blue[100] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(msg, style: const TextStyle(fontSize: 15)),
                              ),
                            )),
                            ...webrtc.filePreviews.reversed.map((preview) => Align(
                              alignment: preview.isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: InkWell(
                                onTap: () async {
                                  // Open or download file
                                  if (preview.isImage && preview.imageBytes != null) {
                                    // Save to temp and open
                                    final tempDir = await getTemporaryDirectory();
                                    final file = await File('${tempDir.path}/${preview.fileName}').writeAsBytes(preview.imageBytes!);
                                    await FileUtils.openFile(file.path);
                                  } else {
                                    // For non-image, show open dialog or use open_file
                                    // This assumes you have a path; in real app, you might download first
                                    // For demo, just show a snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Open file: ${preview.fileName}')),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (preview.isImage && preview.imageBytes != null)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Image.memory(
                                          preview.imageBytes!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Icon(_fileTypeIcon(preview.fileName), size: 36, color: Colors.blueGrey),
                                      ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(preview.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('${(preview.fileSize / 1024).toStringAsFixed(1)} KB', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      if (webrtc.peerTyping)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 6),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              const Text('Peer is typing...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (webrtc.fileTransferActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: LinearProgressIndicator(value: webrtc.fileProgress),
                  ),
                if (webrtc.fileTransferSuccess)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text('File sent/received!', style: TextStyle(color: Colors.green)),
                  ),
                if (webrtc.fileTransferError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('Error: ${webrtc.fileTransferError}', style: const TextStyle(color: Colors.red)),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Type a message...'),
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            Provider.of<WebRTCProvider>(context, listen: false).sendTyping();
                          }
                        },
                        onSubmitted: (val) => _send(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _send(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      tooltip: 'Send file',
                      onPressed: () => _pickAndSendFile(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _send(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Provider.of<WebRTCProvider>(context, listen: false).sendMessage(text);
    _controller.clear();
  }

  Future<void> _pickAndSendFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      Provider.of<WebRTCProvider>(context, listen: false).sendFile(bytes);
    } else if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileBytes = await File(filePath).readAsBytes();
      Provider.of<WebRTCProvider>(context, listen: false).sendFile(fileBytes);
    }
  }
}
