import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudRelayService {
  static final CloudRelayService _instance = CloudRelayService._internal();
  factory CloudRelayService() => _instance;
  CloudRelayService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      await Firebase.initializeApp();
      _initialized = true;
    }
  }

  Future<String> uploadFile(File file, {Function(double progress)? onProgress}) async {
    await initialize();
    final ref = FirebaseStorage.instance.ref().child('relay/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
    final uploadTask = ref.putFile(file);
    uploadTask.snapshotEvents.listen((event) {
      if (onProgress != null && event.totalBytes > 0) {
        onProgress(event.bytesTransferred / event.totalBytes);
      }
    });
    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<File> downloadFile(String url, String savePath, {Function(double progress)? onProgress}) async {
    await initialize();
    final ref = FirebaseStorage.instance.refFromURL(url);
    final file = File(savePath);
    final downloadTask = ref.writeToFile(file);
    downloadTask.snapshotEvents.listen((event) {
      if (onProgress != null && event.totalBytes > 0) {
        onProgress(event.bytesTransferred / event.totalBytes);
      }
    });
    await downloadTask;
    return file;
  }
}
