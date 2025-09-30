import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/file_transfer_provider.dart';
import '../widgets/file_transfer_progress.dart';
import '../widgets/ios_style_theme.dart';
import '../models/transfer_model.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('File Transfers'),
      ),
      child: Consumer<FileTransferProvider>(
        builder: (context, transferProvider, _) {
          final transfers = transferProvider.transfers;

          if (transfers.isEmpty) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      size: 64,
                      color: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .color
                          ?.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active transfers',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle
                          .copyWith(
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color
                                ?.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'File transfers will appear here',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color
                                ?.withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: FileTransferProgress(
                        transfer: transfer,
                        onCancel: () =>
                            transferProvider.cancelTransfer(transfer.id),
                        onRetry: transfer.status == TransferStatus.failed
                            ? () => transferProvider.retryTransfer(transfer.id)
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
