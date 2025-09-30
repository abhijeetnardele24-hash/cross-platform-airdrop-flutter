import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/transfer_model.dart';

class FileTransferProgress extends StatefulWidget {
  final TransferModel transfer;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const FileTransferProgress({
    super.key,
    required this.transfer,
    this.onCancel,
    this.onRetry,
  });

  @override
  State<FileTransferProgress> createState() => _FileTransferProgressState();
}

class _FileTransferProgressState extends State<FileTransferProgress>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatTransferSpeed(int bytesTransferred, Duration elapsed) {
    if (elapsed.inSeconds == 0) return '0 B/s';
    final bytesPerSecond = bytesTransferred ~/ elapsed.inSeconds;
    return _formatFileSize(bytesPerSecond) + '/s';
  }

  @override
  Widget build(BuildContext context) {
    final transfer = widget.transfer;
    final elapsed = DateTime.now().difference(transfer.startTime);
    final speed = _formatTransferSpeed(transfer.bytesTransferred, elapsed);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: transfer.status == TransferStatus.transferring
              ? _pulseAnimation.value
              : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(transfer.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getStatusColor(transfer.status).withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _getStatusColor(transfer.status).withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getStatusIcon(transfer.status),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transfer.fileName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatFileSize(transfer.bytesTransferred)} / ${_formatFileSize(transfer.fileSize)} • $speed',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (transfer.status.canCancel)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onCancel?.call();
                        },
                        child: const Icon(CupertinoIcons.xmark_circle_fill,
                            color: Colors.white70, size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          // Background track
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Progress bar
                          FractionallySizedBox(
                            widthFactor: transfer.progress,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: _getStatusColor(transfer.status),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(transfer.progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _getStatusText(transfer.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(transfer.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (transfer.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    transfer.errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (transfer.status == TransferStatus.failed &&
                      widget.onRetry != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CupertinoButton(
                        color:
                            CupertinoColors.systemBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onRetry?.call();
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.arrow_clockwise, size: 16),
                            SizedBox(width: 4),
                            Text('Retry', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(TransferStatus status) {
    switch (status) {
      case TransferStatus.pending:
        return CupertinoColors.systemOrange;
      case TransferStatus.transferring:
        return CupertinoColors.systemBlue;
      case TransferStatus.completed:
        return CupertinoColors.systemGreen;
      case TransferStatus.failed:
        return CupertinoColors.systemRed;
      case TransferStatus.cancelled:
        return CupertinoColors.systemGrey;
      case TransferStatus.paused:
        return CupertinoColors.systemYellow;
      case TransferStatus.connecting:
      default:
        return CupertinoColors.systemBlue;
    }
  }

  Widget _getStatusIcon(TransferStatus status) {
    IconData icon;
    switch (status) {
      case TransferStatus.pending:
        icon = CupertinoIcons.clock;
        break;
      case TransferStatus.transferring:
        icon = CupertinoIcons.cloud_upload;
        break;
      case TransferStatus.completed:
        icon = CupertinoIcons.checkmark_circle;
        break;
      case TransferStatus.failed:
        icon = CupertinoIcons.xmark_circle;
        break;
      case TransferStatus.cancelled:
        icon = CupertinoIcons.xmark;
        break;
      case TransferStatus.paused:
        icon = CupertinoIcons.pause_circle;
        break;
      case TransferStatus.connecting:
        icon = CupertinoIcons.cloud;
        break;
      default:
        icon = CupertinoIcons.cloud;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: _getStatusColor(status),
        size: 20,
      ),
    );
  }

  String _getStatusText(TransferStatus status) {
    switch (status) {
      case TransferStatus.pending:
        return 'Pending';
      case TransferStatus.transferring:
        return 'Transferring';
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.failed:
        return 'Failed';
      case TransferStatus.cancelled:
        return 'Cancelled';
      case TransferStatus.paused:
        return 'Paused';
      case TransferStatus.connecting:
        return 'Connecting';
      default:
        return 'Unknown';
    }
  }
}
