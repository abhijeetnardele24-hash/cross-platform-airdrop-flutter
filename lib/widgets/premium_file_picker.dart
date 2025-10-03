import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../theme/ios_theme.dart';
import '../providers/theme_provider.dart';

class PremiumFilePickerWidget extends StatefulWidget {
  final Function(List<String>) onFilesSelected;
  final bool allowMultiple;
  final List<String>? allowedExtensions;

  const PremiumFilePickerWidget({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
    this.allowedExtensions,
  });

  @override
  State<PremiumFilePickerWidget> createState() => _PremiumFilePickerWidgetState();
}

class _PremiumFilePickerWidgetState extends State<PremiumFilePickerWidget>
    with TickerProviderStateMixin {
  final List<String> _selectedFiles = [];
  bool _isLoading = false;
  
  late AnimationController _headerController;
  late AnimationController _gridController;
  late AnimationController _filesController;
  
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _gridScale;
  late Animation<double> _filesOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _filesController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );

    _gridScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _gridController, curve: Curves.elasticOut),
    );

    _filesOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _filesController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _gridController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _gridController.dispose();
    _filesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IOSTheme.backgroundColor(isDark),
            IOSTheme.surfaceColor(isDark),
            IOSTheme.elevatedColor(isDark),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: IOSTheme.cardColor(isDark).withOpacity(0.8),
              border: Border.all(
                color: IOSTheme.separatorColor(isDark).withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(IOSTheme.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAnimatedHeader(isDark),
                    const SizedBox(height: IOSTheme.spacing32),
                    _buildAnimatedGrid(isDark),
                    if (_selectedFiles.isNotEmpty) ...[
                      const SizedBox(height: IOSTheme.spacing24),
                      _buildSelectedFiles(isDark),
                      const SizedBox(height: IOSTheme.spacing24),
                      _buildActionButtons(isDark),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(bool isDark) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: _buildHeader(isDark),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(IOSTheme.spacing24),
      decoration: BoxDecoration(
        gradient: IOSTheme.getGradient(
          IOSTheme.blueGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: IOSTheme.elevatedShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(IOSTheme.spacing12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: const Icon(
              CupertinoIcons.cloud_upload,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: IOSTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Files Instantly',
                  style: IOSTheme.title2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: IOSTheme.spacing4),
                Text(
                  widget.allowMultiple 
                    ? 'Select multiple files for seamless sharing'
                    : 'Choose a single file to share',
                  style: IOSTheme.callout.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedFiles.isNotEmpty)
            _buildClearButton(isDark),
        ],
      ),
    );
  }

  Widget _buildClearButton(bool isDark) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        IOSTheme.lightImpact();
        setState(() {
          _selectedFiles.clear();
        });
        _filesController.reverse();
      },
      child: Container(
        padding: const EdgeInsets.all(IOSTheme.spacing8),
        decoration: BoxDecoration(
          color: IOSTheme.systemRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(IOSTheme.smallRadius),
        ),
        child: Icon(
          CupertinoIcons.clear_circled_solid,
          color: IOSTheme.systemRed,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAnimatedGrid(bool isDark) {
    return AnimatedBuilder(
      animation: _gridController,
      builder: (context, child) {
        return Transform.scale(
          scale: _gridScale.value,
          child: _buildFileTypeGrid(isDark),
        );
      },
    );
  }

  Widget _buildFileTypeGrid(bool isDark) {
    final categories = [
      _FileCategory(
        icon: CupertinoIcons.photo_camera_solid,
        label: 'Photos',
        color: IOSTheme.systemBlue,
        gradient: IOSTheme.blueGradient,
        onTap: () => _pickFiles(FileType.image),
      ),
      _FileCategory(
        icon: CupertinoIcons.videocam_fill,
        label: 'Videos',
        color: IOSTheme.systemRed,
        gradient: IOSTheme.pinkGradient,
        onTap: () => _pickFiles(FileType.video),
      ),
      _FileCategory(
        icon: CupertinoIcons.music_note,
        label: 'Audio',
        color: IOSTheme.systemOrange,
        gradient: IOSTheme.orangeGradient,
        onTap: () => _pickFiles(FileType.audio),
      ),
      _FileCategory(
        icon: CupertinoIcons.doc_text_fill,
        label: 'Documents',
        color: IOSTheme.systemGreen,
        gradient: IOSTheme.greenGradient,
        onTap: () => _pickFiles(FileType.custom, ['pdf', 'doc', 'docx', 'txt']),
      ),
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: IOSTheme.spacing16,
            mainAxisSpacing: IOSTheme.spacing16,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(categories[index], isDark, index);
          },
        ),
        const SizedBox(height: IOSTheme.spacing16),
        _buildBrowseAllButton(isDark),
      ],
    );
  }

  Widget _buildCategoryCard(_FileCategory category, bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _isLoading ? null : () {
          IOSTheme.mediumImpact();
          category.onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: IOSTheme.getGradient(category.gradient),
            borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
            boxShadow: [
              BoxShadow(
                color: category.color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(IOSTheme.spacing20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 36,
                      color: Colors.white,
                    ),
                    const SizedBox(height: IOSTheme.spacing12),
                    Text(
                      category.label,
                      style: IOSTheme.headline.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseAllButton(bool isDark) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isLoading ? null : () {
        IOSTheme.mediumImpact();
        _pickFiles(FileType.any);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: IOSTheme.spacing16,
          horizontal: IOSTheme.spacing20,
        ),
        decoration: BoxDecoration(
          gradient: IOSTheme.getGradient(IOSTheme.purpleGradient),
          borderRadius: BorderRadius.circular(IOSTheme.largeRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: IOSTheme.systemPurple.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.folder_open,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: IOSTheme.spacing12),
            Text(
              'Browse All Files',
              style: IOSTheme.headline.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(width: IOSTheme.spacing12),
              const CupertinoActivityIndicator(radius: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFiles(bool isDark) {
    return AnimatedBuilder(
      animation: _filesController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _filesOpacity,
          child: child!,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(IOSTheme.spacing16),
        decoration: BoxDecoration(
          color: IOSTheme.cardColor(isDark).withOpacity(0.5),
          borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
          border: Border.all(
            color: IOSTheme.separatorColor(isDark),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Files (${_selectedFiles.length})',
              style: IOSTheme.headline.copyWith(
                color: IOSTheme.primaryTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: IOSTheme.spacing12),
            ...List.generate(_selectedFiles.length, (index) {
              return _buildFileItem(_selectedFiles[index], index, isDark);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(String filePath, int index, bool isDark) {
    final fileName = path.basename(filePath);
    final file = File(filePath);

    return FutureBuilder<int>(
      future: file.length(),
      builder: (context, snapshot) {
        final fileSize = snapshot.data ?? 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: IOSTheme.spacing8),
          padding: const EdgeInsets.all(IOSTheme.spacing12),
          decoration: BoxDecoration(
            color: IOSTheme.backgroundColor(isDark),
            borderRadius: BorderRadius.circular(IOSTheme.smallRadius),
          ),
          child: Row(
            children: [
              _getFileIcon(fileName),
              const SizedBox(width: IOSTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: IOSTheme.callout.copyWith(
                        color: IOSTheme.primaryTextColor(isDark),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatFileSize(fileSize),
                      style: IOSTheme.caption1.copyWith(
                        color: IOSTheme.secondaryTextColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () {
                  IOSTheme.lightImpact();
                  setState(() {
                    _selectedFiles.removeAt(index);
                  });
                  if (_selectedFiles.isEmpty) {
                    _filesController.reverse();
                  }
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
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : () {
            IOSTheme.mediumImpact();
            widget.onFilesSelected(_selectedFiles);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: IOSTheme.spacing16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [IOSTheme.systemBlue, IOSTheme.systemTeal],
              ),
              borderRadius: BorderRadius.circular(IOSTheme.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: IOSTheme.systemBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.arrow_right_circle_fill,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: IOSTheme.spacing8),
                Text(
                  'Share ${_selectedFiles.length} File${_selectedFiles.length > 1 ? 's' : ''}',
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
        iconData = CupertinoIcons.photo;
        color = IOSTheme.systemBlue;
        break;
      case '.mp4':
      case '.avi':
      case '.mov':
        iconData = CupertinoIcons.videocam;
        color = IOSTheme.systemRed;
        break;
      case '.mp3':
      case '.wav':
      case '.m4a':
        iconData = CupertinoIcons.music_note;
        color = IOSTheme.systemOrange;
        break;
      case '.pdf':
        iconData = CupertinoIcons.doc_text;
        color = IOSTheme.systemRed;
        break;
      case '.doc':
      case '.docx':
        iconData = CupertinoIcons.doc_text;
        color = IOSTheme.systemBlue;
        break;
      default:
        iconData = CupertinoIcons.doc;
        color = IOSTheme.systemGray;
    }

    return Container(
      padding: const EdgeInsets.all(IOSTheme.spacing8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(IOSTheme.smallRadius),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Future<void> _pickFiles(FileType type, [List<String>? allowedExtensions]) async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: widget.allowMultiple,
        allowedExtensions: allowedExtensions ?? widget.allowedExtensions,
      );

      if (result != null) {
        final newFiles = result.paths.where((path) => path != null).cast<String>();
        
        setState(() {
          if (widget.allowMultiple) {
            _selectedFiles.addAll(
              newFiles.where((file) => !_selectedFiles.contains(file))
            );
          } else {
            _selectedFiles.clear();
            _selectedFiles.addAll(newFiles);
          }
        });

        if (_selectedFiles.isNotEmpty) {
          _filesController.forward();
        }
      }
    } catch (e) {
      _showErrorDialog('Error selecting files: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
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

class _FileCategory {
  final IconData icon;
  final String label;
  final Color color;
  final List<Color> gradient;
  final VoidCallback onTap;

  _FileCategory({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });
}
