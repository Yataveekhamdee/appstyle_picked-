import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final _storage = FirebaseStorage.instance;

  // =============== Uploads ===============

  /// อัปโหลดรูปทั่วไป (Mobile)
  static Future<String> uploadImage({
    required File imageFile,
    required String folderPath,
    String? fileName,
  }) async {
    try {
      final originalName = kIsWeb
          ? 'web_image'
          : _safeBaseName(imageFile.path) ?? 'image_file';
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_$originalName';
      final ref = _storage.ref().child('$folderPath/$name');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalName': originalName,
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );

      await ref.putFile(imageFile, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('ไม่สามารถอัปโหลดรูปภาพได้: $e');
    }
  }

  /// อัปโหลดรูปสินค้า (รองรับ Mobile และ Web ผ่าน bytes)
  static Future<String> uploadProductImage(File imageFile, {String? productId}) async {
    try {
      const folderPath = 'products';
      final fileName = productId != null
          ? '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : null;

      if (kIsWeb) {
        return await _uploadFileWeb(imageFile, folderPath, fileName);
      }
      return await uploadImage(
        imageFile: imageFile,
        folderPath: folderPath,
        fileName: fileName,
      );
    } catch (e) {
      throw Exception('ไม่สามารถอัปโหลดรูปภาพสินค้าได้: $e');
    }
  }

  /// อัปโหลดรูปสินค้าจาก bytes (Web)
  static Future<String> uploadProductImageBytes(
    Uint8List imageBytes, {
    String? productId,
  }) async {
    try {
      const folderPath = 'products';
      final fileName = productId != null
          ? '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : null;
      return await _uploadBytesWeb(imageBytes, folderPath, fileName);
    } catch (e) {
      throw Exception('ไม่สามารถอัปโหลดรูปภาพจาก bytes ได้: $e');
    }
  }

  // =============== Web internal ===============

  static Future<String> _uploadFileWeb(
    File imageFile,
    String folderPath,
    String? fileName,
  ) async {
    try {
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_web_image.jpg';
      final ref = _storage.ref().child('$folderPath/$name');

      // พยายามอ่าน bytes จาก File (บน web บางกรณี path เป็น data:uri)
      final bytes = await _readBytesFallback(imageFile);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'platform': 'web',
          'originalName': 'web_uploaded_image',
        },
      );

      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('ไม่สามารถอัปโหลดไฟล์ใน Web platform ได้: $e');
    }
  }

  static Future<String> _uploadBytesWeb(
    Uint8List imageBytes,
    String folderPath,
    String? fileName,
  ) async {
    try {
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_web_image.jpg';
      final ref = _storage.ref().child('$folderPath/$name');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'platform': 'web',
          'originalName': 'web_uploaded_image',
          'size': imageBytes.length.toString(),
        },
      );

      await ref.putData(imageBytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      // ถ้าเจอ CORS ให้ตั้งค่า CORS ของ Firebase Storage สำหรับ localhost
      if (e.toString().contains('CORS') ||
          e.toString().contains('blocked') ||
          e.toString().contains('XMLHttpRequest')) {
        throw Exception('CORS Error: กรุณาตั้งค่า Firebase Storage CORS สำหรับ localhost');
      }
      throw Exception('ไม่สามารถอัปโหลด bytes ใน Web platform ได้: $e');
    }
  }

  // =============== File Ops ===============

  static Future<void> deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      throw Exception('ไม่สามารถลบรูปภาพได้: $e');
    }
  }

  static Future<FullMetadata> getFileMetadata(String imageUrl) async {
    try {
      return await _storage.refFromURL(imageUrl).getMetadata();
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลไฟล์ได้: $e');
    }
  }

  static Future<List<Reference>> listFiles(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      throw Exception('ไม่สามารถดึงรายการไฟล์ได้: $e');
    }
  }

  static Future<void> deleteMultipleImages(List<String> imageUrls) async {
    try {
      await Future.wait(imageUrls.map(deleteImage));
    } catch (e) {
      throw Exception('ไม่สามารถลบรูปภาพหลายไฟล์ได้: $e');
    }
  }

  // =============== Validators / Utils ===============

  static bool isAllowedImageType(String filePath) {
    if (filePath.isEmpty) return false;
    const exts = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final ext = path.extension(filePath).toLowerCase();
    if (exts.contains(ext)) return true;
    final lower = filePath.toLowerCase();
    return exts.any(lower.endsWith);
  }

  static bool isValidFileSize(File file, {int maxSizeInMB = 10}) {
    if (kIsWeb) return true; // บนเว็บไปตรวจตอน putData แทน
    try {
      return file.lengthSync() <= maxSizeInMB * 1024 * 1024;
    } catch (_) {
      return true;
    }
  }

  static bool isValidBytesSize(List<int> bytes, {int maxSizeInMB = 10}) {
    return bytes.length <= maxSizeInMB * 1024 * 1024;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // =============== Internals ===============

  static String? _safeBaseName(String? p) {
    if (p == null || p.isEmpty) return null;
    try {
      return path.basename(p);
    } catch (_) {
      return p.split('/').last;
    }
  }

  static Future<Uint8List> _readBytesFallback(File file) async {
    try {
      return await file.readAsBytes();
    } catch (_) {
      final data = file.uri.data; // เผื่อกรณี path เป็น data:uri บน web
      if (data != null) return data.contentAsBytes();
      rethrow;
    }
  }
}
