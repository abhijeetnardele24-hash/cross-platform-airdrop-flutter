import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/ios_theme.dart';

class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({super.key});

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Sent', 'Received', 'Failed'];

  // Mock transfer history data
  final List<TransferHistoryItem> _transferHistory = [
    TransferHistoryItem(
      id: '1',
      fileName: 'vacation_photos.zip',
      fileSize: '25.4 MB',
      deviceName: 'John\'s iPhone',
      type: TransferType.sent,
      status: TransferStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TransferHistoryItem(
      id: '2',
      fileName: 'presentation.pdf',
      fileSize: '3.2 MB',
      deviceName: 'Sarah\'s MacBook',
      type: TransferType.received,
      status: TransferStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TransferHistoryItem(
      id: '3',
      fileName: 'music_collection.zip',
      fileSize: '156.8 MB',
      deviceName: 'Mike\'s Android',
      type: TransferType.sent,
      status: TransferStatus.failed,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransferHistoryItem(
      id: '4',
      fileName: 'document.docx',
      fileSize: '1.1 MB',
      deviceName: 'Office PC',
      type: TransferType.received,
      status: TransferStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    final filteredHistory = _getFilteredHistory();

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSTheme.cardColor(isDark).withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: IOSTheme.separatorColor(isDark),
            width: 0.5,
          ),
        ),
        middle: Text(
          'Transfer History',
          style: IOSTheme.headline.copyWith(
            color: IOSTheme.primaryTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showFilterOptions,
          child: Icon(
            CupertinoIcons.line_horizontal_3_decrease,
            color: IOSTheme.systemBlue,
            size: 24,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Statistics Card
            _buildStatisticsCard(isDark),
            
            // Filter Chips
            _buildFilterChips(isDark),
            
            // History List
            Expanded(
              child: filteredHistory.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final item = filteredHistory[index];
                        return _buildHistoryItem(item, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(bool isDark) {
    final totalTransfers = _transferHistory.length;
    final successfulTransfers = _transferHistory
        .where((item) => item.status == TransferStatus.completed)
        .length;
    final totalSize = _transferHistory
        .where((item) => item.status == TransferStatus.completed)
        .length * 15.2; // Mock calculation

    return Container(
      margin: const EdgeInsets.all(16),
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
          Text(
            'Statistics',
            style: IOSTheme.title3.copyWith(
              color: IOSTheme.primaryTextColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Transfers',
                  totalTransfers.toString(),
                  CupertinoIcons.arrow_up_arrow_down,
                  IOSTheme.systemBlue,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Successful',
                  successfulTransfers.toString(),
                  CupertinoIcons.checkmark_circle,
                  IOSTheme.systemGreen,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Data Shared',
                  '${totalSize.toStringAsFixed(1)} MB',
                  CupertinoIcons.cloud,
                  IOSTheme.systemPurple,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: IOSTheme.title3.copyWith(
            color: IOSTheme.primaryTextColor(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: IOSTheme.caption1.copyWith(
            color: IOSTheme.secondaryTextColor(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                IOSTheme.lightImpact();
                setState(() {
                  _selectedFilter = option;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? IOSTheme.systemBlue
                      : IOSTheme.cardColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? IOSTheme.systemBlue
                        : IOSTheme.separatorColor(isDark),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: IOSTheme.body.copyWith(
                    color: isSelected
                        ? Colors.white
                        : IOSTheme.primaryTextColor(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(TransferHistoryItem item, bool isDark) {
    final statusColor = _getStatusColor(item.status);
    final typeIcon = _getTypeIcon(item.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IOSTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              typeIcon,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  style: IOSTheme.headline.copyWith(
                    color: IOSTheme.primaryTextColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.type.name.toUpperCase()} • ${item.deviceName}',
                  style: IOSTheme.caption1.copyWith(
                    color: IOSTheme.secondaryTextColor(isDark),
                  ),
                ),
                Text(
                  '${item.fileSize} • ${_formatTimestamp(item.timestamp)}',
                  style: IOSTheme.caption2.copyWith(
                    color: IOSTheme.secondaryTextColor(isDark).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.status.name.toUpperCase(),
              style: IOSTheme.caption2.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: IOSTheme.systemGray.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.clock,
              color: IOSTheme.systemGray,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No transfer history',
            style: IOSTheme.title2.copyWith(
              color: IOSTheme.primaryTextColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your file transfers will appear here',
            style: IOSTheme.body.copyWith(
              color: IOSTheme.secondaryTextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  List<TransferHistoryItem> _getFilteredHistory() {
    if (_selectedFilter == 'All') return _transferHistory;
    
    return _transferHistory.where((item) {
      switch (_selectedFilter) {
        case 'Sent':
          return item.type == TransferType.sent;
        case 'Received':
          return item.type == TransferType.received;
        case 'Failed':
          return item.status == TransferStatus.failed;
        default:
          return true;
      }
    }).toList();
  }

  Color _getStatusColor(TransferStatus status) {
    switch (status) {
      case TransferStatus.completed:
        return IOSTheme.systemGreen;
      case TransferStatus.failed:
        return IOSTheme.systemRed;
      case TransferStatus.inProgress:
        return IOSTheme.systemBlue;
    }
  }

  IconData _getTypeIcon(TransferType type) {
    switch (type) {
      case TransferType.sent:
        return CupertinoIcons.arrow_up_circle;
      case TransferType.received:
        return CupertinoIcons.arrow_down_circle;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showFilterOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter History'),
        actions: _filterOptions.map((option) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _selectedFilter = option;
              });
              Navigator.pop(context);
            },
            child: Text(option),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

// Data Models
class TransferHistoryItem {
  final String id;
  final String fileName;
  final String fileSize;
  final String deviceName;
  final TransferType type;
  final TransferStatus status;
  final DateTime timestamp;

  TransferHistoryItem({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.deviceName,
    required this.type,
    required this.status,
    required this.timestamp,
  });
}

enum TransferType { sent, received }
enum TransferStatus { completed, failed, inProgress }
