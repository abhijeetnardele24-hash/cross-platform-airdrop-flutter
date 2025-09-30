import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/drag_drop_zone.dart';
import '../widgets/swipeable_list_item.dart';
import '../widgets/notification_banner.dart';
import '../utils/thumbnail_generator.dart';
import 'dart:io';

/// Screen to test advanced UI features
class AdvancedUITestScreen extends StatefulWidget {
  const AdvancedUITestScreen({super.key});

  @override
  State<AdvancedUITestScreen> createState() => _AdvancedUITestScreenState();
}

class _AdvancedUITestScreenState extends State<AdvancedUITestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _selectedFiles = [];
  final List<String> _transferHistory = [
    'Document.pdf',
    'Image.jpg',
    'Video.mp4',
    'Archive.zip',
    'Presentation.pptx',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced UI Features'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.image), text: 'Thumbnails'),
            Tab(icon: Icon(Icons.upload_file), text: 'Drag & Drop'),
            Tab(icon: Icon(Icons.swipe), text: 'Swipe Actions'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThumbnailsTab(),
          _buildDragDropTab(),
          _buildSwipeActionsTab(),
          _buildNotificationsTab(),
        ],
      ),
    );
  }

  Widget _buildThumbnailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'File Thumbnails',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Automatic thumbnail generation for images and videos',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          if (_selectedFiles.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.photo_library, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No files selected',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use the Drag & Drop tab to select files',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return _buildThumbnailCard(file);
              },
            ),
          
          const SizedBox(height: 24),
          const Text(
            'File Type Icons',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildFileTypeIcons(),
        ],
      ),
    );
  }

  Widget _buildThumbnailCard(String filePath) {
    final fileName = filePath.split(Platform.pathSeparator).last;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: FileThumbnail(
                filePath: filePath,
                size: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeIcons() {
    final fileTypes = [
      ('image.jpg', 'Image'),
      ('video.mp4', 'Video'),
      ('audio.mp3', 'Audio'),
      ('document.pdf', 'Document'),
      ('archive.zip', 'Archive'),
      ('code.dart', 'Code'),
      ('file.txt', 'Other'),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: fileTypes.map((type) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                ThumbnailGenerator.getFileIcon(type.$1),
                size: 32,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type.$2,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDragDropTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Drag & Drop Zones',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drag files or tap to browse',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Full drag drop zone
          const Text(
            'Full Zone',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          DragDropZone(
            onFilesSelected: (files) {
              setState(() {
                _selectedFiles = files;
              });
              NotificationBanner.show(
                context: context,
                title: 'Files Selected',
                message: '${files.length} file(s) selected',
                type: NotificationBannerType.success,
              );
            },
            allowMultiple: true,
            hintText: 'Drop your files here',
            height: 200,
          ),
          
          const SizedBox(height: 24),
          
          // Compact drag drop zone
          const Text(
            'Compact Zone',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          CompactDragDropZone(
            onFilesSelected: (files) {
              setState(() {
                _selectedFiles.addAll(files);
              });
              NotificationBanner.show(
                context: context,
                title: 'Files Added',
                message: '${files.length} file(s) added',
                type: NotificationBannerType.info,
              );
            },
            allowMultiple: true,
            hintText: 'Add more files',
          ),
          
          const SizedBox(height: 24),
          
          // Selected files list
          if (_selectedFiles.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Files (${_selectedFiles.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedFiles.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_selectedFiles.length, (index) {
              final file = _selectedFiles[index];
              final fileName = file.split(Platform.pathSeparator).last;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    ThumbnailGenerator.getFileIcon(file),
                    color: Colors.blue,
                  ),
                  title: Text(fileName),
                  subtitle: Text(file),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSwipeActionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Swipe to Delete',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Swipe left on items to reveal delete action',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _transferHistory.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final item = _transferHistory[index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SwipeableListItem(
                  onDelete: () {
                    setState(() {
                      _transferHistory.removeAt(index);
                    });
                    NotificationBanner.show(
                      context: context,
                      title: 'Deleted',
                      message: '$item has been removed',
                      type: NotificationBannerType.success,
                    );
                  },
                  confirmDelete: true,
                  deleteConfirmTitle: 'Delete Transfer',
                  deleteConfirmMessage: 'Remove $item from history?',
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Icon(
                          ThumbnailGenerator.getFileIcon(item),
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(item),
                      subtitle: Text('Transferred ${index + 1} hour(s) ago'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_transferHistory.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No transfer history',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Notification Banners',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'iOS-style notification banners with animations',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Success notification
          _buildNotificationButton(
            label: 'Success Notification',
            color: Colors.green,
            icon: Icons.check_circle,
            onPressed: () {
              NotificationBanner.show(
                context: context,
                title: 'Transfer Complete',
                message: 'File has been sent successfully',
                type: NotificationBannerType.success,
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Error notification
          _buildNotificationButton(
            label: 'Error Notification',
            color: Colors.red,
            icon: Icons.error,
            onPressed: () {
              NotificationBanner.show(
                context: context,
                title: 'Transfer Failed',
                message: 'Unable to send file. Please try again.',
                type: NotificationBannerType.error,
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Warning notification
          _buildNotificationButton(
            label: 'Warning Notification',
            color: Colors.orange,
            icon: Icons.warning,
            onPressed: () {
              NotificationBanner.show(
                context: context,
                title: 'Low Storage',
                message: 'Device storage is running low',
                type: NotificationBannerType.warning,
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Info notification
          _buildNotificationButton(
            label: 'Info Notification',
            color: Colors.blue,
            icon: Icons.info,
            onPressed: () {
              NotificationBanner.show(
                context: context,
                title: 'New Device Found',
                message: 'iPhone 14 Pro is nearby',
                type: NotificationBannerType.info,
              );
            },
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          const Text(
            'Compact Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          
          _buildNotificationButton(
            label: 'Compact Success',
            color: Colors.green,
            icon: Icons.check,
            onPressed: () {
              CompactNotificationBanner.show(
                context: context,
                message: 'File saved successfully',
                icon: CupertinoIcons.checkmark_alt,
                backgroundColor: Colors.green,
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildNotificationButton(
            label: 'Compact Info',
            color: Colors.blue,
            icon: Icons.info_outline,
            onPressed: () {
              CompactNotificationBanner.show(
                context: context,
                message: 'Connecting to device...',
                icon: CupertinoIcons.wifi,
                backgroundColor: Colors.blue,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
