import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/ios_theme.dart';
import '../theme/ios_typography.dart';

class EnhancedSendScreen extends StatefulWidget {
  const EnhancedSendScreen({super.key});

  @override
  State<EnhancedSendScreen> createState() => _EnhancedSendScreenState();
}

class _EnhancedSendScreenState extends State<EnhancedSendScreen> {
  List<PlatformFile> _selectedFiles = [];
  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.9),
        border: null,
        middle: Text(
          'Send Files',
          style: IOSTypography.withColor(
            IOSTypography.navigationTitle,
            CupertinoColors.label.resolveFrom(context),
          ),
        ),
        trailing: _selectedFiles.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _clearSelection,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: IOSTheme.systemRed,
                    fontSize: 16,
                  ),
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedFiles.isEmpty) ...[
                const SizedBox(height: 60),
                _buildEmptyState(),
              ] else ...[
                const SizedBox(height: 20),
                _buildSelectedFiles(),
                const SizedBox(height: 30),
                _buildSendButton(),
              ],
              
              const SizedBox(height: 40),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              
              const SizedBox(height: 20),
              
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IOSTheme.systemBlue,
                IOSTheme.systemBlue.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: IOSTheme.systemBlue.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.paperplane_fill,
            color: Colors.white,
            size: 60,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Send Files',
          style: IOSTypography.withColor(
            IOSTypography.largeTitle,
            CupertinoColors.label.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Select files from your device to share with nearby users',
          style: IOSTypography.withColor(
            IOSTypography.body,
            CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        CupertinoButton.filled(
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          onPressed: _isSelecting ? null : _pickFiles,
          child: _isSelecting
              ? const CupertinoActivityIndicator(color: Colors.white)
              : const Text(
                  'Choose Files',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Files (${_selectedFiles.length})',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 16),
        ...(_selectedFiles.map((file) => _buildFileItem(file)).toList()),
        const SizedBox(height: 20),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSelecting ? null : _pickMoreFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: IOSTheme.systemBlue.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.add,
                  color: IOSTheme.systemBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add More Files',
                  style: TextStyle(
                    color: IOSTheme.systemBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    final fileSize = _formatFileSize(file.size);
    final fileIcon = _getFileIcon(file.extension ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: fileIcon.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              fileIcon.icon,
              color: fileIcon.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  fileSize,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _removeFile(file),
            child: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: IOSTheme.systemRed,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: double.infinity,
      child: CupertinoButton.filled(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        onPressed: _sendFiles,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.paperplane_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Send ${_selectedFiles.length} File${_selectedFiles.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(
              child: _buildRectangularActionCard(
                'Photos',
                CupertinoIcons.photo_on_rectangle,
                [IOSTheme.systemPink, IOSTheme.systemPink.withOpacity(0.8)],
                () => _pickSpecificFiles(FileType.image),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRectangularActionCard(
                'Documents',
                CupertinoIcons.doc_text_fill,
                [IOSTheme.systemBlue, IOSTheme.systemBlue.withOpacity(0.8)],
                () => _pickSpecificFiles(FileType.any),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Second row
        Row(
          children: [
            Expanded(
              child: _buildRectangularActionCard(
                'Videos',
                CupertinoIcons.videocam_fill,
                [IOSTheme.systemPurple, IOSTheme.systemPurple.withOpacity(0.8)],
                () => _pickSpecificFiles(FileType.video),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRectangularActionCard(
                'Audio',
                CupertinoIcons.music_note_2,
                [IOSTheme.systemOrange, IOSTheme.systemOrange.withOpacity(0.8)],
                () => _pickSpecificFiles(FileType.audio),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRectangularActionCard(
    String title,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey2.resolveFrom(context),
              size: 16,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    setState(() {
      _isSelecting = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showError('Failed to pick files: $e');
    } finally {
      setState(() {
        _isSelecting = false;
      });
    }
  }

  Future<void> _pickMoreFiles() async {
    setState(() {
      _isSelecting = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showError('Failed to pick files: $e');
    } finally {
      setState(() {
        _isSelecting = false;
      });
    }
  }

  Future<void> _pickSpecificFiles(FileType type) async {
    setState(() {
      _isSelecting = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: type,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showError('Failed to pick files: $e');
    } finally {
      setState(() {
        _isSelecting = false;
      });
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
    HapticFeedback.lightImpact();
  }

  void _clearSelection() {
    setState(() {
      _selectedFiles.clear();
    });
    HapticFeedback.lightImpact();
  }

  void _sendFiles() {
    HapticFeedback.mediumImpact();
    // Implement file sending logic here
    _showSuccess('Files sent successfully!');
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  ({IconData icon, Color color}) _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return (icon: CupertinoIcons.doc_text_fill, color: IOSTheme.systemRed);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return (icon: CupertinoIcons.photo_fill, color: IOSTheme.systemPink);
      case 'mp4':
      case 'mov':
      case 'avi':
        return (icon: CupertinoIcons.videocam_fill, color: IOSTheme.systemPurple);
      case 'mp3':
      case 'wav':
      case 'aac':
        return (icon: CupertinoIcons.music_note, color: IOSTheme.systemOrange);
      case 'zip':
      case 'rar':
        return (icon: CupertinoIcons.archivebox_fill, color: IOSTheme.systemYellow);
      default:
        return (icon: CupertinoIcons.doc_fill, color: IOSTheme.systemBlue);
    }
  }
}
