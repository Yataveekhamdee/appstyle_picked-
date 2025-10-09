import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String> uploadSlip(String uid, String orderId, File file) async {
    final ref = FirebaseStorage.instance.ref('users/$uid/slips/$orderId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
