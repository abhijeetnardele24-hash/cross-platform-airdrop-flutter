class TransferTask {
  final String id;
  final String fileName;
  final int fileSize;
  final bool isSending;
  double progress;
  String? error;
  bool isComplete;

  TransferTask({
    required this.id,
    required this.fileName,
    required this.fileSize,
    this.isSending = false,
    this.progress = 0.0,
    this.error,
    this.isComplete = false,
  });
}
