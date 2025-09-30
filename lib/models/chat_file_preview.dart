import 'dart:typed_data';

class ChatFilePreview {
  final String fileName;
  final int fileSize;
  final bool isImage;
  final Uint8List? imageBytes;
  final bool isMe;

  ChatFilePreview({
    required this.fileName,
    required this.fileSize,
    required this.isImage,
    this.imageBytes,
    required this.isMe,
  });
}
