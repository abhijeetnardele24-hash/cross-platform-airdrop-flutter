import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

/// Utility for generating thumbnails for images and videos
class ThumbnailGenerator {
  static final Map<String, Uint8List> _cache = {};

  /// Generate thumbnail for a file
  static Future<Uint8List?> generateThumbnail(
    String filePath, {
    int maxWidth = 200,
    int maxHeight = 200,
    int quality = 80,
  }) async {
    try {
      // Check cache first
      if (_cache.containsKey(filePath)) {
        return _cache[filePath];
      }

      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ File does not exist: $filePath');
        return null;
      }

      final extension = path.extension(filePath).toLowerCase();
      Uint8List? thumbnail;

      if (_isImage(extension)) {
        thumbnail = await _generateImageThumbnail(
          filePath,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );
      } else if (_isVideo(extension)) {
        thumbnail = await _generateVideoThumbnail(
          filePath,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );
      }

      // Cache the thumbnail
      if (thumbnail != null) {
        _cache[filePath] = thumbnail;
      }

      return thumbnail;
    } catch (e) {
      debugPrint('❌ Error generating thumbnail: $e');
      return null;
    }
  }

  /// Generate thumbnail for an image file
  static Future<Uint8List?> _generateImageThumbnail(
    String filePath, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      // Decode image
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Convert to bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ Error generating image thumbnail: $e');
      return null;
    }
  }

  /// Generate thumbnail for a video file
  static Future<Uint8List?> _generateVideoThumbnail(
    String filePath, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: filePath,
        imageFormat: ImageFormat.PNG,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );

      return thumbnail;
    } catch (e) {
      debugPrint('❌ Error generating video thumbnail: $e');
      return null;
    }
  }

  /// Check if file is an image
  static bool _isImage(String extension) {
    const imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.heic',
      '.heif',
    ];
    return imageExtensions.contains(extension);
  }

  /// Check if file is a video
  static bool _isVideo(String extension) {
    const videoExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      '.flv',
      '.wmv',
      '.m4v',
      '.3gp',
    ];
    return videoExtensions.contains(extension);
  }

  /// Get icon for file type
  static IconData getFileIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    if (_isImage(extension)) {
      return Icons.image;
    } else if (_isVideo(extension)) {
      return Icons.videocam;
    } else if (_isAudio(extension)) {
      return Icons.audiotrack;
    } else if (_isDocument(extension)) {
      return Icons.description;
    } else if (_isArchive(extension)) {
      return Icons.folder_zip;
    } else if (_isCode(extension)) {
      return Icons.code;
    } else {
      return Icons.insert_drive_file;
    }
  }

  /// Check if file is audio
  static bool _isAudio(String extension) {
    const audioExtensions = [
      '.mp3',
      '.wav',
      '.aac',
      '.flac',
      '.m4a',
      '.ogg',
      '.wma',
    ];
    return audioExtensions.contains(extension);
  }

  /// Check if file is a document
  static bool _isDocument(String extension) {
    const documentExtensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.rtf',
      '.odt',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
    ];
    return documentExtensions.contains(extension);
  }

  /// Check if file is an archive
  static bool _isArchive(String extension) {
    const archiveExtensions = [
      '.zip',
      '.rar',
      '.7z',
      '.tar',
      '.gz',
      '.bz2',
    ];
    return archiveExtensions.contains(extension);
  }

  /// Check if file is code
  static bool _isCode(String extension) {
    const codeExtensions = [
      '.dart',
      '.java',
      '.kt',
      '.swift',
      '.js',
      '.ts',
      '.py',
      '.cpp',
      '.c',
      '.h',
      '.html',
      '.css',
      '.json',
      '.xml',
    ];
    return codeExtensions.contains(extension);
  }

  /// Clear thumbnail cache
  static void clearCache() {
    _cache.clear();
    debugPrint('🗑️ Thumbnail cache cleared');
  }

  /// Get cache size
  static int getCacheSize() {
    return _cache.length;
  }
}

/// Widget to display file thumbnail
class FileThumbnail extends StatefulWidget {
  final String filePath;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const FileThumbnail({
    super.key,
    required this.filePath,
    this.size = 80,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<FileThumbnail> createState() => _FileThumbnailState();
}

class _FileThumbnailState extends State<FileThumbnail> {
  Uint8List? _thumbnail;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    try {
      final thumbnail = await ThumbnailGenerator.generateThumbnail(
        widget.filePath,
        maxWidth: widget.size.toInt() * 2,
        maxHeight: widget.size.toInt() * 2,
      );

      if (mounted) {
        setState(() {
          _thumbnail = thumbnail;
          _isLoading = false;
          _hasError = thumbnail == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_hasError || _thumbnail == null) {
      return Center(
        child: Icon(
          ThumbnailGenerator.getFileIcon(widget.filePath),
          size: widget.size * 0.5,
          color: Colors.grey[600],
        ),
      );
    }

    return Image.memory(
      _thumbnail!,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            ThumbnailGenerator.getFileIcon(widget.filePath),
            size: widget.size * 0.5,
            color: Colors.grey[600],
          ),
        );
      },
    );
  }
}
