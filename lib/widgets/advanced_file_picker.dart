import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../theme/ios_theme.dart';
import '../providers/theme_provider.dart';

class AdvancedFilePickerWidget extends StatefulWidget {
  final Function(List<String>) onFilesSelected;
  final bool allowMultiple;
  final List<String>? allowedExtensions;

  const AdvancedFilePickerWidget({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
    this.allowedExtensions,
  });

  @override
  State<AdvancedFilePickerWidget> createState() => _AdvancedFilePickerWidgetState();
}

class _AdvancedFilePickerWidgetState extends State<AdvancedFilePickerWidget>
    with TickerProviderStateMixin {
  final List<String> _selectedFiles = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeCard(isDark),
              const SizedBox(height: 24),
              _buildQuickSelectSection(isDark),
              const SizedBox(height: 24),
              _buildFileCategories(isDark),
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSelectedFilesSection(isDark),
              ],
              const SizedBox(height: 32),
              _buildActionSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IOSTheme.systemBlue.withOpacity(0.1),
            IOSTheme.systemPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: IOSTheme.systemBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [IOSTheme.systemBlue, IOSTheme.systemPurple],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: IOSTheme.systemBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.share_up,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share Files Instantly',
            style: IOSTheme.title2.copyWith(
              color: IOSTheme.primaryTextColor(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select files from your device to share with nearby devices',
            style: IOSTheme.body.copyWith(
              color: IOSTheme.secondaryTextColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.folder,
                color: IOSTheme.systemOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Select',
                style: IOSTheme.title3.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isLoading ? null : () => _pickFiles(FileType.any),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [IOSTheme.systemBlue, IOSTheme.systemBlue.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: IOSTheme.systemBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const CupertinoActivityIndicator(color: Colors.white)
                  else
                    const Icon(CupertinoIcons.doc_on_doc, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _isLoading ? 'Selecting Files...' : 'Browse All Files',
                    style: IOSTheme.headline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCategories(bool isDark) {
    final categories = [
      FileCategory('Photos', CupertinoIcons.photo_camera_solid, IOSTheme.systemBlue, FileType.image),
      FileCategory('Videos', CupertinoIcons.videocam_fill, IOSTheme.systemRed, FileType.video),
      FileCategory('Audio', CupertinoIcons.music_note, IOSTheme.systemOrange, FileType.audio),
      FileCategory('Documents', CupertinoIcons.doc_text_fill, IOSTheme.systemGreen, null),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'File Categories',
            style: IOSTheme.title3.copyWith(
              color: IOSTheme.primaryTextColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(FileCategory category, bool isDark) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isLoading ? null : () => _pickFiles(category.fileType ?? FileType.any),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: IOSTheme.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: category.color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: IOSTheme.headline.copyWith(
                color: IOSTheme.primaryTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Files (${_selectedFiles.length})',
                style: IOSTheme.title3.copyWith(
                  color: IOSTheme.primaryTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _selectedFiles.clear();
                  });
                },
                child: Text(
                  'Clear All',
                  style: IOSTheme.body.copyWith(
                    color: IOSTheme.systemRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final filePath = _selectedFiles[index];
              final fileName = path.basename(filePath);
              final fileSize = _getFileSize(filePath);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: IOSTheme.systemGray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(fileName),
                      color: IOSTheme.systemBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: IOSTheme.body.copyWith(
                              color: IOSTheme.primaryTextColor(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            fileSize,
                            style: IOSTheme.caption1.copyWith(
                              color: IOSTheme.secondaryTextColor(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedFiles.removeAt(index);
                        });
                      },
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: IOSTheme.systemRed,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(bool isDark) {
    return Column(
      children: [
        if (_selectedFiles.isNotEmpty)
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              IOSTheme.mediumImpact();
              widget.onFilesSelected(_selectedFiles);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [IOSTheme.systemGreen, IOSTheme.systemGreen.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: IOSTheme.systemGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.paperplane_fill, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Share ${_selectedFiles.length} File${_selectedFiles.length > 1 ? 's' : ''}',
                    style: IOSTheme.headline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Files will be shared securely with nearby devices',
          style: IOSTheme.caption1.copyWith(
            color: IOSTheme.secondaryTextColor(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _pickFiles(FileType fileType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      IOSTheme.lightImpact();
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: widget.allowMultiple,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null) {
        setState(() {
          if (widget.allowMultiple) {
            _selectedFiles.addAll(result.paths.where((path) => path != null).cast<String>());
          } else {
            _selectedFiles.clear();
            if (result.paths.first != null) {
              _selectedFiles.add(result.paths.first!);
            }
          }
        });
        IOSTheme.mediumImpact();
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return 'Unknown size';
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return CupertinoIcons.photo;
      case '.mp4':
      case '.mov':
      case '.avi':
        return CupertinoIcons.videocam;
      case '.mp3':
      case '.wav':
      case '.aac':
        return CupertinoIcons.music_note;
      case '.pdf':
        return CupertinoIcons.doc_text;
      case '.doc':
      case '.docx':
        return CupertinoIcons.doc_text_fill;
      case '.zip':
      case '.rar':
        return CupertinoIcons.archivebox;
      default:
        return CupertinoIcons.doc;
    }
  }
}

class FileCategory {
  final String name;
  final IconData icon;
  final Color color;
  final FileType? fileType;

  FileCategory(this.name, this.icon, this.color, this.fileType);
}
