import 'package:flutter/foundation.dart';
import '../models/transfer_task.dart';

class TransferProvider extends ChangeNotifier {
  final List<TransferTask> _tasks = [];
  List<TransferTask> get tasks => _tasks;

  void addTask(TransferTask task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateProgress(TransferTask task, double progress) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index].progress = progress;
      notifyListeners();
    }
  }

  void markSuccess(TransferTask task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index].isComplete = true;
      notifyListeners();
    }
  }

  void markError(TransferTask task, String error) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index].error = error;
      notifyListeners();
    }
  }

  void cancelTransfer(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
