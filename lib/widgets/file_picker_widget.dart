import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class FilePickerWidget extends StatefulWidget {
  final Function(List<String>) onFilesSelected;
  final bool allowMultiple;
  final List<String>? allowedExtensions;

  const FilePickerWidget({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
    this.allowedExtensions,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  final List<String> _selectedFiles = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 500,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFEFEFE), // warmWhite
            Color(0xFFF8FAFC), // softGray
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 24,
            offset: const Offset(-12, -12),
            spreadRadius: -12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFileTypeButtons(),
                const SizedBox(height: 20),
                if (_selectedFiles.isNotEmpty) ...[
                  _buildSelectedFilesList(),
                  const SizedBox(height: 20),
                ],
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.2),
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            CupertinoIcons.share,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Files to Share',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.allowMultiple
                      ? '📱 Choose multiple files to share'
                      : '📱 Choose a single file to share',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedFiles.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _clearSelection,
              child: const Icon(CupertinoIcons.clear_circled_solid,
                  color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildFileTypeButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.list_bullet,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'File Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildFileTypeButton(
              icon: Icons.photo_camera_rounded,
              label: 'Photos',
              emoji: '📸',
              color: const Color(0xFF1E3A8A), // royalBlue
              onPressed: () => _pickFiles(FileType.image),
            ),
            _buildFileTypeButton(
              icon: Icons.videocam_rounded,
              label: 'Videos',
              emoji: '🎥',
              color: const Color(0xFFDC2626), // crimsonRed
              onPressed: () => _pickFiles(FileType.video),
            ),
            _buildFileTypeButton(
              icon: Icons.music_note_rounded,
              label: 'Audio',
              emoji: '🎵',
              color: const Color(0xFFD97706), // goldenAmber
              onPressed: () => _pickFiles(FileType.audio),
            ),
            _buildFileTypeButton(
              icon: Icons.description_rounded,
              label: 'Documents',
              emoji: '📄',
              color: const Color(0xFF059669), // emeraldGreen
              onPressed: () =>
                  _pickFiles(FileType.custom, ['pdf', 'doc', 'docx', 'txt']),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFileTypeButton(
          icon: Icons.folder_open_rounded,
          label: 'Browse All Files',
          emoji: '📁',
          color: const Color(0xFF7C3AED), // deepPurple
          onPressed: () => _pickFiles(FileType.any),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildFileTypeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    String? emoji,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: isFullWidth ? 56 : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: _isLoading ? null : onPressed,
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment:
              isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (emoji != null) ...[
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
            ] else ...[
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: isFullWidth ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (_isLoading && isFullWidth) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 16,
                height: 16,
                child: CupertinoActivityIndicator(
                  radius: 8,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Files (${_selectedFiles.length})',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_selectedFiles.length, (index) {
            final filePath = _selectedFiles[index];
            return _buildFileItem(filePath, index);
          }),
        ],
      ),
    );
  }

  Widget _buildFileItem(String filePath, int index) {
    final fileName = path.basename(filePath);
    final file = File(filePath);

    return FutureBuilder<int>(
      future: file.length(),
      builder: (context, snapshot) {
        final fileSize = snapshot.data ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _getFileIcon(fileName),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatFileSize(fileSize),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => _removeFile(index),
                child: const Icon(CupertinoIcons.xmark,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    IconData iconData;
    Color color;

    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        iconData = Icons.image;
        color = Colors.blue;
        break;
      case '.mp4':
      case '.avi':
      case '.mov':
        iconData = Icons.movie;
        color = Colors.red;
        break;
      case '.mp3':
      case '.wav':
      case '.m4a':
        iconData = Icons.music_note;
        color = Colors.orange;
        break;
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        color = Colors.blue;
        break;
      case '.txt':
        iconData = Icons.text_snippet;
        color = Colors.grey;
        break;
      case '.zip':
      case '.rar':
        iconData = Icons.archive;
        color = Colors.amber;
        break;
      default:
        iconData = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Icon(
      iconData,
      color: color,
      size: 24,
    );
  }

  Widget _buildActionButtons() {
    if (_selectedFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CupertinoButton(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            onPressed: _isLoading ? null : _sendFiles,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CupertinoActivityIndicator(
                      radius: 10,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Processing...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    CupertinoIcons.arrow_right_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Send ${_selectedFiles.length} File${_selectedFiles.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedFiles.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: CupertinoButton(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            onPressed: _isLoading ? null : () => _pickFiles(FileType.any),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.plus,
                  color: Colors.grey[700],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add More Files',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFiles(FileType type,
      [List<String>? allowedExtensions]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: widget.allowMultiple && _selectedFiles.isEmpty,
        allowedExtensions: allowedExtensions ?? widget.allowedExtensions,
      );

      if (result != null) {
        final newFiles =
            result.paths.where((path) => path != null).cast<String>();

        setState(() {
          if (widget.allowMultiple) {
            _selectedFiles.addAll(
                newFiles.where((file) => !_selectedFiles.contains(file)));
          } else {
            _selectedFiles.clear();
            _selectedFiles.addAll(newFiles);
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Error selecting files: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  void _sendFiles() {
    if (_selectedFiles.isNotEmpty) {
      widget.onFilesSelected(_selectedFiles);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
