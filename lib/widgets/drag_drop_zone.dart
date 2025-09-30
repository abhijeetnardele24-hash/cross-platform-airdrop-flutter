import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

/// Drag and drop zone for file selection
class DragDropZone extends StatefulWidget {
  final Function(List<String>) onFilesSelected;
  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final String? hintText;
  final IconData? icon;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;

  const DragDropZone({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
    this.allowedExtensions,
    this.hintText,
    this.icon,
    this.activeColor,
    this.inactiveColor,
    this.height = 200,
  });

  @override
  State<DragDropZone> createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      Haptics.vibrate(HapticsType.selection);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: widget.allowedExtensions != null
            ? FileType.custom
            : FileType.any,
        allowMultiple: widget.allowMultiple,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null) {
        final files =
            result.paths.where((path) => path != null).cast<String>().toList();
        if (files.isNotEmpty) {
          Haptics.vibrate(HapticsType.success);
          widget.onFilesSelected(files);
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking files: $e');
      Haptics.vibrate(HapticsType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = widget.activeColor ??
        (isDark ? Colors.blue[300]! : Colors.blue[600]!);
    final inactiveColor = widget.inactiveColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[300]!);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: _pickFiles,
        child: DragTarget<List<String>>(
          onWillAccept: (data) {
            setState(() => _isDragging = true);
            _controller.forward();
            Haptics.vibrate(HapticsType.selection);
            return true;
          },
          onAccept: (data) {
            setState(() => _isDragging = false);
            _controller.reverse();
            Haptics.vibrate(HapticsType.success);
            widget.onFilesSelected(data);
          },
          onLeave: (data) {
            setState(() => _isDragging = false);
            _controller.reverse();
          },
          builder: (context, candidateData, rejectedData) {
            return DottedBorder(
              color: _isDragging ? activeColor : inactiveColor,
              strokeWidth: 2,
              dashPattern: const [8, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(16),
              child: Container(
                height: widget.height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isDragging
                      ? activeColor.withOpacity(0.1)
                      : (isDark
                          ? Colors.grey[850]
                          : Colors.grey[50]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon ?? Icons.cloud_upload_outlined,
                      size: 64,
                      color: _isDragging ? activeColor : inactiveColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isDragging
                          ? 'Drop files here'
                          : (widget.hintText ?? 'Drag & drop files here'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _isDragging ? activeColor : inactiveColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'or tap to browse',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Compact drag and drop zone
class CompactDragDropZone extends StatefulWidget {
  final Function(List<String>) onFilesSelected;
  final bool allowMultiple;
  final String? hintText;

  const CompactDragDropZone({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
    this.hintText,
  });

  @override
  State<CompactDragDropZone> createState() => _CompactDragDropZoneState();
}

class _CompactDragDropZoneState extends State<CompactDragDropZone> {
  bool _isDragging = false;

  Future<void> _pickFiles() async {
    try {
      Haptics.vibrate(HapticsType.selection);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: widget.allowMultiple,
      );

      if (result != null) {
        final files =
            result.paths.where((path) => path != null).cast<String>().toList();
        if (files.isNotEmpty) {
          Haptics.vibrate(HapticsType.success);
          widget.onFilesSelected(files);
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _pickFiles,
      child: DragTarget<List<String>>(
        onWillAccept: (data) {
          setState(() => _isDragging = true);
          Haptics.vibrate(HapticsType.selection);
          return true;
        },
        onAccept: (data) {
          setState(() => _isDragging = false);
          Haptics.vibrate(HapticsType.success);
          widget.onFilesSelected(data);
        },
        onLeave: (data) {
          setState(() => _isDragging = false);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isDragging
                  ? Colors.blue.withOpacity(0.1)
                  : (isDark ? Colors.grey[800] : Colors.grey[100]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDragging
                    ? Colors.blue
                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                width: 2,
                style: _isDragging ? BorderStyle.solid : BorderStyle.none,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: _isDragging
                      ? Colors.blue
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.hintText ?? 'Add files',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _isDragging
                        ? Colors.blue
                        : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Draggable file item
class DraggableFileItem extends StatelessWidget {
  final String filePath;
  final Widget child;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const DraggableFileItem({
    super.key,
    required this.filePath,
    required this.child,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<List<String>>(
      data: [filePath],
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: 0.8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: child,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      onDragStarted: () {
        Haptics.vibrate(HapticsType.medium);
        onDragStarted?.call();
      },
      onDragEnd: (details) {
        onDragEnd?.call();
      },
      child: child,
    );
  }
}
