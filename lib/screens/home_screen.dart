import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/device_model.dart';
import '../models/transfer_task.dart'; // Only import, do not define TransferTask here
import '../providers/device_provider.dart';
import '../providers/file_transfer_provider.dart';
import '../providers/room_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transfer_provider.dart';
import '../services/file_transfer_service.dart';
import '../widgets/glass_morphism_card.dart';
import '../widgets/custom_icon.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/qr_share_widget.dart';
import '../screens/settings_screen.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _joinCode = '';
  late FileTransferService _fileTransferService;
  bool _isTransferServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    _fileTransferService = FileTransferService();
  }

  @override
  void dispose() {
    _fileTransferService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'AirDrop',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.settings,
            color: CupertinoColors.activeBlue,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => SettingsScreen()),
            );
          },
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              backgroundColor:
                  CupertinoColors.systemBackground.withOpacity(0.8),
              activeColor: CupertinoColors.activeBlue,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.arrow_up_circle_fill),
                  label: 'Send',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.arrow_down_circle_fill),
                  label: 'Receive',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.chart_bar_fill),
                  label: 'History',
                ),
              ],
            ),
            tabBuilder: (context, index) {
              return CupertinoPageScaffold(
                backgroundColor: Colors.transparent,
                child: _buildTab(index, context),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, BuildContext context) {
    switch (index) {
      case 0:
        return _buildSendTab(context);
      case 1:
        return _buildReceiveTab(context);
      case 2:
        return _buildHistoryTab(context);
      default:
        return _buildSendTab(context);
    }
  }

  Widget _buildSendTab(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).brightness ==
            Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Consumer<RoomProvider>(
            builder: (context, roomProvider, _) {
              final status = roomProvider.status;
              if (!roomProvider.inRoom) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline,
                                size: 18, color: Colors.blue),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                status,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.blue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: 160,
                      child: CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: roomProvider.createRoom,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.add),
                            SizedBox(width: 8),
                            Text('Create Room'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          child: CupertinoTextField(
                            placeholder: 'Enter Code',
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: CupertinoColors.systemGrey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onChanged: (val) => setState(() => _joinCode = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: const Text('Join'),
                          onPressed: () {
                            if (_joinCode.isNotEmpty) {
                              roomProvider.joinRoom(_joinCode);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                );
              } else if (roomProvider.isHost) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Room Code:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SelectableText(roomProvider.roomCode ?? '',
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 12),
                    QRShareWidget(
                      data: roomProvider.roomCode ?? '',
                      label: 'Scan to join',
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      onPressed: roomProvider.leaveRoom,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close),
                          SizedBox(width: 8),
                          Text('Leave Room'),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Joined Room:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SelectableText(roomProvider.roomCode ?? '',
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 12),
                    CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close),
                          SizedBox(width: 8),
                          Text('Leave Room'),
                        ],
                      ),
                      onPressed: roomProvider.leaveRoom,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Consumer<DeviceProvider>(
            builder: (context, deviceProvider, _) {
              final devices = deviceProvider.discoveredDevices;
              if (devices.isEmpty) {
                return GlassMorphismCard(
                  blur: 12.0,
                  opacity: 0.12,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomIcon(
                        icon: Icons.devices,
                        size: 36,
                        color: isDark ? Colors.white38 : Colors.black38,
                        animate: true,
                        duration: const Duration(milliseconds: 800),
                      ),
                      const SizedBox(height: 12),
                      Text('No devices found',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('Devices on your network will appear here',
                          style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 14)),
                    ],
                  ),
                );
              }
              return Material(
                color: Colors.transparent,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      title: Text(device.name ?? 'Unknown Device',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black)),
                      subtitle: Text(device.type.displayName,
                          style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700)),
                      trailing: Icon(Icons.devices, color: Colors.blue),
                      onTap: () {/* connect logic */},
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer<RoomProvider>(
            builder: (context, roomProvider, _) {
              if (!roomProvider.inRoom) {
                return const SizedBox.shrink();
              }
              return Consumer<FileTransferProvider>(
                builder: (context, transferProvider, _) {
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Room active - Ready to transfer files',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                      ),
                      FilePickerWidget(
                        onFilesSelected: (files) async {
                          // Initialize transfer service if needed
                          if (!_isTransferServiceInitialized) {
                            await _initializeFileTransferService(
                                roomProvider.roomCode ?? 'default',
                                roomProvider.isHost);
                          }

                          // Send files
                          await _sendFiles(files);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Selected ${files.length} file(s) for transfer')),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Display active transfers from FileTransferProvider
                      if (transferProvider.activeTransfers.isNotEmpty)
                        Material(
                          color: Colors.transparent,
                          child: Column(
                            children: transferProvider.activeTransfers.map(
                              (transfer) => ListTile(
                                title: Text(transfer.fileName),
                                subtitle: LinearProgressIndicator(
                                    value: transfer.progress),
                                trailing: IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    transferProvider.cancelTransfer(transfer.id);
                                  },
                                ),
                              ),
                            ).toList(),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _buildServerStatusCard(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Available Devices',
                    style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : Colors.black.withOpacity(0.7),
                        fontSize: 16)),
              ),
              Flexible(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIcon(
                        icon: Icons.refresh,
                        color: Colors.blue,
                        bounceOnTap: true,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                          child: Text('Refresh',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildNotConnectedCard(isDark),
        ],
      ),
    );
  }

  Widget _buildReceiveTab(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          GlassMorphismCard(
            blur: 12.0,
            opacity: 0.12,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CustomIcon(
                  icon: Icons.download,
                  color: isDark ? Colors.white38 : Colors.black38,
                  size: 48,
                  animate: true,
                  duration: const Duration(milliseconds: 900),
                ),
                const SizedBox(height: 16),
                Text('Receive Files',
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Files sent to you will appear here',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          GlassMorphismCard(
            blur: 12.0,
            opacity: 0.12,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transfer Statistics',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                        label: 'Total',
                        value: '0',
                        icon: Icons.swap_horiz,
                        color: Colors.blue,
                        isDark: isDark),
                    _StatItem(
                        label: 'Success',
                        value: '0',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        isDark: isDark),
                    _StatItem(
                        label: 'Failed',
                        value: '0',
                        icon: Icons.error,
                        color: Colors.red,
                        isDark: isDark),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                        label: 'Success Rate',
                        value: '0%',
                        icon: Icons.show_chart,
                        color: Colors.orange,
                        isDark: isDark),
                    _StatItem(
                        label: 'Data Transferred',
                        value: '0 B',
                        icon: Icons.pie_chart,
                        color: Colors.purple,
                        isDark: isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassMorphismCard(
            blur: 12.0,
            opacity: 0.12,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CustomIcon(
                  icon: Icons.history,
                  color: isDark ? Colors.white38 : Colors.black38,
                  size: 48,
                  animate: true,
                  duration: const Duration(milliseconds: 900),
                ),
                const SizedBox(height: 16),
                Text('No transfer history',
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Your completed and failed transfers will appear here',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerStatusCard() {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
        final isConnected = deviceProvider.isConnected;
        return GlassMorphismCard(
          blur: 10.0,
          opacity: isConnected ? 0.1 : 0.08,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CustomIcon(
                  icon: isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 32,
                  animate: true,
                  duration: const Duration(milliseconds: 700),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected
                            ? 'Connected to Server'
                            : 'Not Connected to Server',
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isConnected
                            ? 'Ready to transfer files'
                            : 'Check your internet connection',
                        style: TextStyle(
                            color: isConnected ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ),
                CustomIcon(
                  icon: isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                  bounceOnTap: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotConnectedCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: CupertinoColors.systemGrey5.withOpacity(0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.wifi_slash,
                size: 48,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(height: 16),
              Text(
                'Not Connected to Server',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your internet connection',
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 15,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // Retry connection logic
                },
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Initialize file transfer service with callbacks
  Future<void> _initializeFileTransferService(
      String sessionCode, bool isHost) async {
    final localContext = context;
    try {
      final transferProvider =
          Provider.of<TransferProvider>(localContext, listen: false);

      // Set up callbacks
      _fileTransferService.onFileSendProgress = (fileName, progress) {
        // Find or create task
        final existingTask = transferProvider.tasks.firstWhere(
          (task) => task.fileName == fileName && task.isSending,
          orElse: () {
            final file = File(fileName);
            final task = TransferTask(
              id: fileName, // or use a unique id
              fileName: fileName,
              fileSize: file.existsSync() ? file.lengthSync() : 0,
              isSending: true,
            );
            transferProvider.addTask(task);
            return task;
          },
        );
        transferProvider.updateProgress(existingTask, progress);
      };

      _fileTransferService.onFileSendComplete = (fileName) {
        final task = transferProvider.tasks.firstWhere(
          (task) => task.fileName == fileName && task.isSending,
          orElse: () => TransferTask(
            id: fileName,
            fileName: fileName,
            fileSize: 0,
            isSending: true,
          ),
        );
        transferProvider.markSuccess(task);
      };

      _fileTransferService.onFileSendError = (fileName, error) {
        final task = transferProvider.tasks.firstWhere(
          (task) => task.fileName == fileName && task.isSending,
          orElse: () => TransferTask(
            id: fileName,
            fileName: fileName,
            fileSize: 0,
            isSending: true,
          ),
        );
        transferProvider.markError(task, error);
      };

      _fileTransferService.onFileReceiveStart = (fileName, fileSize) {
        final task = TransferTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fileName: fileName,
          fileSize: fileSize,
          isSending: false,
        );
        transferProvider.addTask(task);
      };

      _fileTransferService.onFileReceiveProgress = (fileName, progress) {
        final task = transferProvider.tasks.firstWhere(
          (task) => task.fileName == fileName && !task.isSending,
          orElse: () => TransferTask(
            id: fileName,
            fileName: fileName,
            fileSize: 0,
            isSending: false,
          ),
        );
        transferProvider.updateProgress(task, progress);
      };

      _fileTransferService.onFileReceiveComplete = (fileName, filePath) {
        final task = transferProvider.tasks.firstWhere(
          (task) => task.fileName == fileName && !task.isSending,
          orElse: () => TransferTask(
            id: fileName,
            fileName: fileName,
            fileSize: 0,
            isSending: false,
          ),
        );
        transferProvider.markSuccess(task);

        if (mounted) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            SnackBar(
              content: Text('File received: $fileName'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () {
                  // TODO: Open file
                },
              ),
            ),
          );
        }
      };

      _fileTransferService.onFileReceiveError = (fileName, error) {
        final task = transferProvider.tasks.firstWhere(
          (task) => task.fileName == fileName && !task.isSending,
          orElse: () => TransferTask(
            id: fileName,
            fileName: fileName,
            fileSize: 0,
            isSending: false,
          ),
        );
        transferProvider.markError(task, error);
      };

      _fileTransferService.onDeviceConnected = (deviceId) {
        if (mounted) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            SnackBar(content: Text('Device connected: $deviceId')),
          );
        }
      };

      _fileTransferService.onDeviceDisconnected = () {
        if (mounted) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            const SnackBar(content: Text('Device disconnected')),
          );
        }
      };

      // Initialize the service
      await _fileTransferService.initialize(sessionCode, isHost: isHost);
      _isTransferServiceInitialized = true;

      debugPrint('✅ File transfer service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing file transfer service: $e');
      if (mounted) {
        ScaffoldMessenger.of(localContext).showSnackBar(
          SnackBar(content: Text('Error initializing transfer: $e')),
        );
      }
    }
  }

  /// Send selected files
  Future<void> _sendFiles(List<String> filePaths) async {
    final localContext = context;
    try {
      debugPrint('📤 Sending ${filePaths.length} file(s)');

      for (final filePath in filePaths) {
        final file = File(filePath);
        if (!await file.exists()) {
          debugPrint('⚠️ File does not exist: $filePath');
          continue;
        }

        final fileName = filePath.split(Platform.pathSeparator).last;
        final fileSize = await file.length();

        debugPrint('📤 Sending: $fileName ($fileSize bytes)');

        // Create transfer task
        final transferProvider =
            Provider.of<TransferProvider>(localContext, listen: false);
        final task = TransferTask(
          id: fileName, // or use a unique id
          fileName: fileName,
          fileSize: fileSize,
          isSending: true,
        );
        transferProvider.addTask(task);

        // Send file
        await _fileTransferService.sendFile(filePath);
      }

      debugPrint('✅ All files sent');
    } catch (e) {
      debugPrint('❌ Error sending files: $e');
      if (mounted) {
        ScaffoldMessenger.of(localContext).showSnackBar(
          SnackBar(content: Text('Error sending files: $e')),
        );
      }
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
      ],
    );
  }
}
