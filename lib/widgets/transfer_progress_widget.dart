import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transfer_model.dart';
import '../providers/file_transfer_provider.dart';
import 'package:path/path.dart' as path;
import 'vignette_grain_background.dart';

class TransferProgressWidget extends StatelessWidget {
  final TransferModel transfer;
  final bool showDetails;

  const TransferProgressWidget({
    super.key,
    required this.transfer,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 8,
        shadowColor: _getProgressColor().withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: VignetteGrainBackground(
            grainOpacity: 0.03,
            grainDensity: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildProgressBar(context),
                if (showDetails) ...[
                  const SizedBox(height: 12),
                  _buildDetails(context),
                ],
                const SizedBox(height: 12),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildFileIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transfer.fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _buildTransferDescription(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildFileIcon() {
    final extension = path.extension(transfer.fileName).toLowerCase();

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

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: color,
        size: 28,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? iconData;

    switch (transfer.status) {
      case TransferStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        iconData = Icons.schedule;
        break;
      case TransferStatus.connecting:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        iconData = Icons.wifi;
        break;
      case TransferStatus.transferring:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        iconData = Icons.sync;
        break;
      case TransferStatus.paused:
        backgroundColor = Colors.amber.withValues(alpha: 0.1);
        textColor = Colors.amber;
        iconData = Icons.pause;
        break;
      case TransferStatus.completed:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case TransferStatus.failed:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        iconData = Icons.error;
        break;
      case TransferStatus.cancelled:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        iconData = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            transfer.status.displayName,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(transfer.progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_formatBytes(transfer.bytesTransferred)} / ${transfer.formattedFileSize}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: transfer.progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Speed',
                transfer.status.isActive
                    ? transfer.formattedTransferSpeed
                    : '--',
                Icons.speed,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'Time',
                _getTimeRemaining(),
                Icons.access_time,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'From',
                transfer.fromDevice.name,
                Icons.phone_android,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'To',
                transfer.toDevice.name,
                Icons.tablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final transferProvider =
        Provider.of<FileTransferProvider>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (transfer.status.canPause)
          TextButton.icon(
            onPressed: () => transferProvider.pauseTransfer(transfer.id),
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('Pause'),
          ),
        if (transfer.status.canResume)
          TextButton.icon(
            onPressed: () => transferProvider.resumeTransfer(transfer.id),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Resume'),
          ),
        if (transfer.status == TransferStatus.failed)
          TextButton.icon(
            onPressed: () => transferProvider.retryTransfer(transfer.id),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        if (transfer.status.canCancel)
          TextButton.icon(
            onPressed: () => _showCancelDialog(context, transferProvider),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        if (transfer.status == TransferStatus.completed ||
            transfer.status == TransferStatus.cancelled ||
            transfer.status == TransferStatus.failed)
          TextButton.icon(
            onPressed: () => transferProvider.removeTransfer(transfer.id),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Remove'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
          ),
      ],
    );
  }

  String _buildTransferDescription() {
    final direction = transfer.direction == TransferDirection.send
        ? 'Sending to'
        : 'Receiving from';
    final deviceName = transfer.direction == TransferDirection.send
        ? transfer.toDevice.name
        : transfer.fromDevice.name;
    return '$direction $deviceName';
  }

  Color _getProgressColor() {
    switch (transfer.status) {
      case TransferStatus.transferring:
        return Colors.blue;
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
        return Colors.red;
      case TransferStatus.paused:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getTimeRemaining() {
    if (!transfer.status.isActive || transfer.transferSpeed == 0) {
      return '--';
    }

    final remainingBytes = transfer.fileSize - transfer.bytesTransferred;
    final secondsRemaining = remainingBytes / transfer.transferSpeed;

    if (secondsRemaining < 60) {
      return '${secondsRemaining.toInt()}s';
    } else if (secondsRemaining < 3600) {
      return '${(secondsRemaining / 60).toInt()}m';
    } else {
      return '${(secondsRemaining / 3600).toStringAsFixed(1)}h';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showCancelDialog(
      BuildContext context, FileTransferProvider transferProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Transfer'),
        content: Text(
            'Are you sure you want to cancel the transfer of "${transfer.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              transferProvider.cancelTransfer(transfer.id);
            },
            child: const Text('Yes'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
