## Advanced UI Features Guide

## Overview
Advanced UI components including file thumbnails, drag-and-drop zones, swipe-to-delete actions, and iOS-style notification banners. All features are optimized for performance and include haptic feedback.

## Features Implemented

### 1. File Thumbnail Generation (`lib/utils/thumbnail_generator.dart`)

#### ThumbnailGenerator
Utility class for generating thumbnails from images and videos.

**Features:**
- Automatic thumbnail generation for images
- Video thumbnail extraction
- In-memory caching for performance
- File type icon detection
- Configurable size and quality

**Usage:**
```dart
// Generate thumbnail
final thumbnail = await ThumbnailGenerator.generateThumbnail(
  '/path/to/file.jpg',
  maxWidth: 200,
  maxHeight: 200,
  quality: 80,
);

// Get file type icon
final icon = ThumbnailGenerator.getFileIcon('/path/to/document.pdf');
// Returns: Icons.description

// Clear cache
ThumbnailGenerator.clearCache();
```

**Supported File Types:**
- **Images**: jpg, jpeg, png, gif, bmp, webp, heic, heif
- **Videos**: mp4, mov, avi, mkv, flv, wmv, m4v, 3gp
- **Audio**: mp3, wav, aac, flac, m4a, ogg, wma
- **Documents**: pdf, doc, docx, txt, rtf, odt, xls, xlsx, ppt, pptx
- **Archives**: zip, rar, 7z, tar, gz, bz2
- **Code**: dart, java, kt, swift, js, ts, py, cpp, c, h, html, css, json, xml

#### FileThumbnail Widget
Widget to display file thumbnails with loading and error states.

**Usage:**
```dart
FileThumbnail(
  filePath: '/path/to/image.jpg',
  size: 120,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(12),
)
```

**Features:**
- Automatic loading indicator
- Error fallback with file type icon
- Configurable size and border radius
- Memory efficient

### 2. Drag-and-Drop Zones (`lib/widgets/drag_drop_zone.dart`)

#### DragDropZone
Full-featured drag-and-drop zone with animations.

**Features:**
- Drag and drop support
- Tap to browse files
- Animated hover state
- Dotted border design
- Haptic feedback
- Multiple file selection

**Usage:**
```dart
DragDropZone(
  onFilesSelected: (files) {
    print('Selected: ${files.length} files');
  },
  allowMultiple: true,
  allowedExtensions: ['jpg', 'png', 'pdf'],
  hintText: 'Drop your files here',
  icon: Icons.cloud_upload,
  height: 200,
)
```

**Parameters:**
- `onFilesSelected`: Callback with selected file paths
- `allowMultiple`: Allow multiple file selection
- `allowedExtensions`: Filter by file extensions
- `hintText`: Custom hint text
- `icon`: Custom icon
- `activeColor`: Color when dragging
- `inactiveColor`: Default color
- `height`: Zone height

#### CompactDragDropZone
Compact version for inline file selection.

**Usage:**
```dart
CompactDragDropZone(
  onFilesSelected: (files) {
    // Handle files
  },
  allowMultiple: true,
  hintText: 'Add files',
)
```

#### DraggableFileItem
Make any widget draggable.

**Usage:**
```dart
DraggableFileItem(
  filePath: '/path/to/file.pdf',
  onDragStarted: () => print('Drag started'),
  onDragEnd: () => print('Drag ended'),
  child: ListTile(
    title: Text('file.pdf'),
  ),
)
```

### 3. Swipe-to-Delete (`lib/widgets/swipeable_list_item.dart`)

#### SwipeableListItem
iOS-style swipeable list item with delete confirmation.

**Features:**
- Swipe left to reveal delete button
- Optional delete confirmation dialog
- Smooth animations
- Haptic feedback
- Customizable colors

**Usage:**
```dart
SwipeableListItem(
  onDelete: () {
    // Handle delete
  },
  confirmDelete: true,
  deleteConfirmTitle: 'Delete Item',
  deleteConfirmMessage: 'Are you sure?',
  deleteColor: Colors.red,
  child: ListTile(
    title: Text('Swipe me'),
  ),
)
```

**Parameters:**
- `child`: Widget to display
- `onDelete`: Delete callback
- `onArchive`: Archive callback (optional)
- `onShare`: Share callback (optional)
- `confirmDelete`: Show confirmation dialog
- `deleteConfirmTitle`: Confirmation title
- `deleteConfirmMessage`: Confirmation message
- `deleteColor`: Delete button color

#### AdvancedSwipeableItem
Multiple swipe actions on both sides.

**Usage:**
```dart
AdvancedSwipeableItem(
  leftActions: [
    SwipeAction(
      icon: Icons.archive,
      color: Colors.orange,
      onPressed: () => archive(),
    ),
  ],
  rightActions: [
    SwipeAction(
      icon: Icons.delete,
      color: Colors.red,
      onPressed: () => delete(),
    ),
  ],
  child: YourWidget(),
)
```

#### SlidableListItem
iOS Mail-style slideable actions.

**Usage:**
```dart
SlidableListItem(
  actions: [
    SlidableAction(
      icon: Icons.share,
      color: Colors.blue,
      onPressed: () => share(),
      label: 'Share',
    ),
    SlidableAction(
      icon: Icons.delete,
      color: Colors.red,
      onPressed: () => delete(),
      label: 'Delete',
    ),
  ],
  child: ListTile(title: Text('Item')),
)
```

### 4. Notification Banners (`lib/widgets/notification_banner.dart`)

#### NotificationBanner
iOS-style notification banner with blur effect.

**Features:**
- Slide-in animation from top
- Blur background (glass morphism)
- Auto-dismiss
- Tap to dismiss
- Swipe up to dismiss
- Haptic feedback
- Four types: success, error, warning, info

**Usage:**
```dart
NotificationBanner.show(
  context: context,
  title: 'Transfer Complete',
  message: 'File has been sent successfully',
  type: NotificationBannerType.success,
  duration: Duration(seconds: 3),
  onTap: () {
    // Handle tap
  },
)
```

**Notification Types:**
```dart
// Success - Green with checkmark
NotificationBannerType.success

// Error - Red with X mark
NotificationBannerType.error

// Warning - Orange with exclamation
NotificationBannerType.warning

// Info - Blue with info icon
NotificationBannerType.info
```

**Custom Icon and Color:**
```dart
NotificationBanner.show(
  context: context,
  title: 'Custom Notification',
  message: 'With custom icon and color',
  icon: Icons.star,
  iconColor: Colors.purple,
)
```

#### CompactNotificationBanner
Compact notification for quick feedback.

**Usage:**
```dart
CompactNotificationBanner.show(
  context: context,
  message: 'File saved',
  icon: Icons.check,
  backgroundColor: Colors.green,
  duration: Duration(seconds: 2),
)
```

**Features:**
- Bottom-center position
- Scale and fade animation
- Minimal design
- Quick feedback

## Testing Screen

Access via: **Settings → Developer Tools → Advanced UI Features**

### Features:
1. **Thumbnails Tab**: View file thumbnails and type icons
2. **Drag & Drop Tab**: Test drag-drop zones and file selection
3. **Swipe Actions Tab**: Try swipe-to-delete on transfer history
4. **Notifications Tab**: Test all notification banner types

## Performance Optimization

### Thumbnail Caching
```dart
// Thumbnails are automatically cached in memory
// Clear cache when needed
ThumbnailGenerator.clearCache();

// Check cache size
final cacheSize = ThumbnailGenerator.getCacheSize();
print('Cached thumbnails: $cacheSize');
```

### Lazy Loading
```dart
// Thumbnails load asynchronously
// Shows loading indicator while generating
FileThumbnail(
  filePath: file.path,
  size: 100,
)
```

### Memory Management
- Thumbnails are resized to target dimensions
- Original files are not kept in memory
- Cache is cleared on app restart
- Use `clearCache()` for manual cleanup

## Responsive Design

### Screen Size Adaptation
All components adapt to different screen sizes:

**Small Screens (< 600px):**
- 2 columns for thumbnail grid
- Compact drag-drop zone
- Full-width notifications

**Medium Screens (600-900px):**
- 3 columns for thumbnail grid
- Standard drag-drop zone
- Centered notifications

**Large Screens (> 900px):**
- 4+ columns for thumbnail grid
- Wide drag-drop zone
- Fixed-width notifications

### Orientation Support
- Portrait and landscape modes
- Automatic grid column adjustment
- Responsive padding and margins

## Accessibility

### VoiceOver/TalkBack
All components support screen readers:
```dart
Semantics(
  label: 'Drag and drop zone',
  hint: 'Tap to select files',
  child: DragDropZone(...),
)
```

### Haptic Feedback
Appropriate haptic feedback for all interactions:
- **Selection**: File selection, drag start
- **Success**: File upload, delete confirmation
- **Warning**: Delete action
- **Error**: Upload failure

### High Contrast
Components adapt to high contrast mode:
- Increased border widths
- Higher color contrast
- Clearer visual feedback

## Integration Examples

### Example 1: File Upload with Thumbnails
```dart
class FileUploadScreen extends StatefulWidget {
  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  List<String> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DragDropZone(
          onFilesSelected: (files) {
            setState(() => _selectedFiles = files);
            NotificationBanner.show(
              context: context,
              title: 'Files Selected',
              message: '${files.length} file(s) ready to upload',
              type: NotificationBannerType.success,
            );
          },
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedFiles.length,
          itemBuilder: (context, index) {
            return FileThumbnail(
              filePath: _selectedFiles[index],
              size: 120,
            );
          },
        ),
      ],
    );
  }
}
```

### Example 2: Transfer History with Swipe-to-Delete
```dart
class TransferHistoryScreen extends StatefulWidget {
  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  List<Transfer> _transfers = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _transfers.length,
      itemBuilder: (context, index) {
        final transfer = _transfers[index];
        
        return SwipeableListItem(
          onDelete: () {
            setState(() => _transfers.removeAt(index));
            NotificationBanner.show(
              context: context,
              title: 'Deleted',
              message: 'Transfer removed from history',
              type: NotificationBannerType.success,
            );
          },
          confirmDelete: true,
          child: ListTile(
            leading: FileThumbnail(
              filePath: transfer.filePath,
              size: 50,
            ),
            title: Text(transfer.fileName),
            subtitle: Text(transfer.date),
          ),
        );
      },
    );
  }
}
```

### Example 3: File Transfer with Progress Notifications
```dart
Future<void> sendFile(String filePath) async {
  // Show start notification
  NotificationBanner.show(
    context: context,
    title: 'Sending File',
    message: 'Transfer in progress...',
    type: NotificationBannerType.info,
  );

  try {
    await fileTransferService.send(filePath);
    
    // Show success notification
    NotificationBanner.show(
      context: context,
      title: 'Transfer Complete',
      message: 'File sent successfully',
      type: NotificationBannerType.success,
    );
  } catch (e) {
    // Show error notification
    NotificationBanner.show(
      context: context,
      title: 'Transfer Failed',
      message: e.toString(),
      type: NotificationBannerType.error,
    );
  }
}
```

## Best Practices

### 1. Thumbnail Generation
```dart
// Good: Generate thumbnails asynchronously
Future<void> loadThumbnails() async {
  for (final file in files) {
    await ThumbnailGenerator.generateThumbnail(file);
  }
}

// Avoid: Blocking UI thread
final thumbnail = ThumbnailGenerator.generateThumbnail(file); // Don't await in build
```

### 2. Drag-and-Drop
```dart
// Good: Provide clear visual feedback
DragDropZone(
  hintText: 'Drop images here',
  icon: Icons.image,
  activeColor: Colors.blue,
)

// Avoid: Generic messaging
DragDropZone(
  hintText: 'Drop files',
)
```

### 3. Swipe Actions
```dart
// Good: Always confirm destructive actions
SwipeableListItem(
  confirmDelete: true,
  deleteConfirmTitle: 'Delete File',
  deleteConfirmMessage: 'This cannot be undone',
  onDelete: () => delete(),
)

// Avoid: No confirmation for destructive actions
SwipeableListItem(
  confirmDelete: false, // Dangerous!
  onDelete: () => delete(),
)
```

### 4. Notifications
```dart
// Good: Appropriate notification types
NotificationBanner.show(
  context: context,
  title: 'Error',
  type: NotificationBannerType.error, // Red, error icon
)

// Avoid: Wrong notification type
NotificationBanner.show(
  context: context,
  title: 'Error',
  type: NotificationBannerType.success, // Confusing!
)
```

## Troubleshooting

### Issue: Thumbnails not generating
**Solutions:**
- Check file exists: `File(path).existsSync()`
- Verify file permissions
- Ensure video_thumbnail package is installed
- Check file format is supported
- Test on physical device (some codecs unavailable in simulator)

### Issue: Drag-and-drop not working
**Solutions:**
- Ensure dotted_border package is installed
- Check file_picker permissions
- Test on physical device (drag-drop limited in simulator)
- Verify `onFilesSelected` callback is set

### Issue: Swipe not triggering
**Solutions:**
- Ensure sufficient swipe distance
- Check for conflicting gesture detectors
- Verify `onDelete` callback is set
- Test swipe speed (not too fast/slow)

### Issue: Notifications not showing
**Solutions:**
- Ensure context is valid
- Check overlay is available
- Verify notification not already showing
- Test with different notification types

## Platform-Specific Notes

### iOS
- Drag-and-drop works best on iPad
- Haptic feedback requires physical device
- Thumbnails use native image codecs
- Notifications follow iOS design guidelines

### Android
- Drag-and-drop supported on all devices
- Haptic feedback varies by device
- Video thumbnails may require additional permissions
- Notifications adapt to Material Design

### Desktop
- Full drag-and-drop support
- No haptic feedback
- Thumbnails generated using Dart codecs
- Notifications positioned at top-center

### Web
- Limited drag-and-drop (browser dependent)
- No haptic feedback
- Thumbnails use web codecs
- Notifications use overlay

## Dependencies

```yaml
dependencies:
  video_thumbnail: ^0.5.3  # Video thumbnail generation
  dotted_border: ^2.1.0    # Dotted border for drag-drop zones
  haptic_feedback: ^0.5.1+1  # Haptic feedback
  file_picker: ^8.0.0      # File selection
  path_provider: ^2.1.1    # File paths
```

---

**Status**: ✅ Fully Implemented
**Version**: 1.0.0
**Last Updated**: 2025-10-01
**Team**: Team Narcos

## Quick Reference

| Feature | File | Use Case |
|---------|------|----------|
| FileThumbnail | thumbnail_generator.dart | Display file previews |
| ThumbnailGenerator | thumbnail_generator.dart | Generate thumbnails |
| DragDropZone | drag_drop_zone.dart | File upload zones |
| CompactDragDropZone | drag_drop_zone.dart | Inline file selection |
| SwipeableListItem | swipeable_list_item.dart | Delete from lists |
| AdvancedSwipeableItem | swipeable_list_item.dart | Multiple actions |
| NotificationBanner | notification_banner.dart | Important alerts |
| CompactNotificationBanner | notification_banner.dart | Quick feedback |
