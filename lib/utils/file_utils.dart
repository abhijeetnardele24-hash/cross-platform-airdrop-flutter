import 'dart:io';
import 'package:open_file/open_file.dart';

class FileUtils {
  static Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}
