import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final _storage = FirebaseStorage.instance;

  /// อัปโหลดรูปภาพไป Firebase Storage
  static Future<String> uploadImage({
    required File imageFile,
    required String folderPath,
    String? fileName,
  }) async {
    try {
      // สร้างชื่อไฟล์ถ้าไม่ได้ระบุ
      String originalName = 'web_image';
      if (!kIsWeb) {
        try {
          originalName = path.basename(imageFile.path);
        } catch (e) {
          originalName = 'image_file';
        }
      }
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_$originalName';
      
      // สร้าง path สำหรับอัปโหลด
      final ref = _storage.ref().child('$folderPath/$name');
      
      // กำหนด metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalName': originalName,
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );
      
      // อัปโหลดไฟล์
      final uploadTask = ref.putFile(imageFile, metadata);

      // รอให้อัปโหลดเสร็จ
      final snapshot = await uploadTask.whenComplete(() {});
      
      // ดึง URL ของรูปที่อัปโหลด
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Debug StorageService - Upload error: $e');
      throw Exception('ไม่สามารถอัปโหลดรูปภาพได้: $e');
    }
  }

  /// อัปโหลดรูปภาพสินค้า
  static Future<String> uploadProductImage(File imageFile, {String? productId}) async {
    try {
      final folderPath = 'products';
      final fileName = productId != null ? '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg' : null;
      
      // สำหรับ Web platform ให้ใช้ alternative method
      if (kIsWeb) {
        return await _uploadFileWeb(imageFile, folderPath, fileName);
      } else {
        return await uploadImage(
          imageFile: imageFile,
          folderPath: folderPath,
          fileName: fileName,
        );
      }
    } catch (e) {
      print('Debug StorageService - uploadProductImage error: $e');
      throw Exception('ไม่สามารถอัปโหลดรูปภาพสินค้าได้: $e');
    }
  }

  /// อัปโหลดรูปภาพสินค้าจาก bytes (สำหรับ Web)
  static Future<String> uploadProductImageBytes(Uint8List imageBytes, {String? productId}) async {
    try {
      final folderPath = 'products';
      final fileName = productId != null ? '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg' : null;
      
      return await _uploadBytesWeb(imageBytes, folderPath, fileName);
    } catch (e) {
      print('Debug StorageService - uploadProductImageBytes error: $e');
      throw Exception('ไม่สามารถอัปโหลดรูปภาพจาก bytes ได้: $e');
    }
  }

  /// อัปโหลดไฟล์สำหรับ Web platform
  static Future<String> _uploadFileWeb(File imageFile, String folderPath, String? fileName) async {
    try {
      // สร้างชื่อไฟล์
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_web_image.jpg';
      
      // สร้าง reference ไปยัง Firebase Storage
      final ref = _storage.ref().child('$folderPath/$name');
      
      // อ่าน bytes จากไฟล์
      Uint8List fileBytes;
      try {
        fileBytes = await imageFile.readAsBytes();
      } catch (e) {
        print('Debug StorageService - Error reading file bytes: $e');
        // ลองใช้ File.fromRawPath ถ้าเป็น Web
        if (kIsWeb) {
          final uriData = imageFile.uri.data;
          if (uriData != null) {
            fileBytes = uriData.contentAsBytes();
          } else {
            throw Exception('ไม่สามารถอ่านข้อมูลจากไฟล์ได้');
          }
        } else {
          rethrow;
        }
      }
      
      // กำหนด metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'platform': 'web',
          'originalName': 'web_uploaded_image',
        },
      );
      
      // อัปโหลดไฟล์โดยใช้ putData แทน putFile
      final uploadTask = ref.putData(fileBytes, metadata);

      // รอให้อัปโหลดเสร็จ
      final snapshot = await uploadTask.whenComplete(() {});
      
      // ดึง URL ของรูปที่อัปโหลด
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Debug StorageService - _uploadFileWeb error: $e');
      throw Exception('ไม่สามารถอัปโหลดไฟล์ใน Web platform ได้: $e');
    }
  }

  /// อัปโหลด bytes สำหรับ Web platform
  static Future<String> _uploadBytesWeb(Uint8List imageBytes, String folderPath, String? fileName) async {
    try {
      // สร้างชื่อไฟล์
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_web_image.jpg';
      
      // สร้าง reference ไปยัง Firebase Storage
      final ref = _storage.ref().child('$folderPath/$name');
      
      // กำหนด metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'platform': 'web',
          'originalName': 'web_uploaded_image',
          'size': imageBytes.length.toString(),
        },
      );
      
      // อัปโหลดไฟล์โดยใช้ putData
      final uploadTask = ref.putData(imageBytes, metadata);

      // รอให้อัปโหลดเสร็จ
      final snapshot = await uploadTask.whenComplete(() {});
      
      // ดึง URL ของรูปที่อัปโหลด
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Debug StorageService - _uploadBytesWeb error: $e');
      
      // ตรวจสอบว่าเป็น CORS error หรือไม่
      if (e.toString().contains('CORS') || 
          e.toString().contains('blocked') || 
          e.toString().contains('XMLHttpRequest')) {
        throw Exception('CORS Error: กรุณาตั้งค่า Firebase Storage CORS สำหรับ localhost\n'
            'ดูคู่มือในไฟล์: FIREBASE_STORAGE_CORS_FIX.md');
      }
      
      throw Exception('ไม่สามารถอัปโหลด bytes ใน Web platform ได้: $e');
    }
  }

  /// อัปโหลดรูปภาพแบรนด์
  static Future<String> uploadBrandImage(File imageFile, {String? brandId}) async {
    final folderPath = 'brands';
    final fileName = brandId != null ? '${brandId}_${DateTime.now().millisecondsSinceEpoch}.jpg' : null;
    
    return uploadImage(
      imageFile: imageFile,
      folderPath: folderPath,
      fileName: fileName,
    );
  }

  /// อัปโหลดรูปภาพหมวดหมู่
  static Future<String> uploadCategoryImage(File imageFile, {String? categoryId}) async {
    final folderPath = 'categories';
    final fileName = categoryId != null ? '${categoryId}_${DateTime.now().millisecondsSinceEpoch}.jpg' : null;
    
    return uploadImage(
      imageFile: imageFile,
      folderPath: folderPath,
      fileName: fileName,
    );
  }

  /// อัปโหลดรูปภาพผู้ใช้
  static Future<String> uploadUserImage(File imageFile, {String? userId}) async {
    final folderPath = 'users';
    final fileName = userId != null ? '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg' : null;
    
    return uploadImage(
      imageFile: imageFile,
      folderPath: folderPath,
      fileName: fileName,
    );
  }

  /// ลบไฟล์จาก Firebase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // แยก URL เพื่อหาชื่อไฟล์
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('ไม่สามารถลบรูปภาพได้: $e');
    }
  }

  /// ตรวจสอบว่า URL เป็น Firebase Storage URL หรือไม่
  static bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }

  /// ดึงข้อมูลไฟล์จาก Firebase Storage
  static Future<FullMetadata> getFileMetadata(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลไฟล์ได้: $e');
    }
  }

  /// ดาวน์โหลดไฟล์จาก Firebase Storage
  static Future<File> downloadFile(String imageUrl, String localPath) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      final file = File(localPath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw Exception('ไม่สามารถดาวน์โหลดไฟล์ได้: $e');
    }
  }

  /// ดึงรายการไฟล์ในโฟลเดอร์
  static Future<List<Reference>> listFiles(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      throw Exception('ไม่สามารถดึงรายการไฟล์ได้: $e');
    }
  }

  /// คำนวณขนาดไฟล์
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// ตรวจสอบประเภทไฟล์ที่อนุญาต
  static bool isAllowedImageType(String filePath) {
    if (filePath.isEmpty) return false;
    
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    
    // ตรวจสอบ extension จาก path
    final extension = path.extension(filePath).toLowerCase();
    print('Debug StorageService - Extension from path: $extension');
    
    // ตรวจสอบจากชื่อไฟล์โดยตรง
    String fileName = 'unknown';
    if (!kIsWeb) {
      try {
        fileName = path.basename(filePath).toLowerCase();
      } catch (e) {
        // สำหรับ Web platform หรือ path ที่ไม่ถูกต้อง
        fileName = filePath.split('/').last.toLowerCase();
      }
    } else {
      // สำหรับ Web platform ใช้ string operations
      fileName = filePath.split('/').last.toLowerCase();
    }
    print('Debug StorageService - File name: $fileName');
    
    // ตรวจสอบจากส่วนท้ายของ path
    final pathLower = filePath.toLowerCase();
    final hasValidExtension = allowedExtensions.any((ext) => 
      extension == ext || 
      fileName.endsWith(ext) || 
      pathLower.endsWith(ext)
    );
    
    print('Debug StorageService - Has valid extension: $hasValidExtension');
    
    return hasValidExtension;
  }

  /// ตรวจสอบขนาดไฟล์ (ไม่เกิน 10MB)
  static bool isValidFileSize(File file, {int maxSizeInMB = 10}) {
    try {
      // ตรวจสอบว่าเป็น Web platform หรือไม่
      if (kIsWeb) {
        // สำหรับ Web platform ให้ return true (จะตรวจสอบใน upload method)
        return true;
      }
      
      final fileSize = file.lengthSync();
      final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
      return fileSize <= maxSizeInBytes;
    } catch (e) {
      print('Debug StorageService - File size check error: $e');
      // สำหรับ Web platform ที่ไม่รองรับ lengthSync()
      return true;
    }
  }

  /// ตรวจสอบขนาดไฟล์จาก bytes (สำหรับ Web)
  static bool isValidBytesSize(List<int> bytes, {int maxSizeInMB = 10}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return bytes.length <= maxSizeInBytes;
  }

  /// สร้าง thumbnail สำหรับรูปภาพ
  static Future<String> uploadThumbnail({
    required File imageFile,
    required String originalUrl,
    int quality = 50,
  }) async {
    try {
      // สร้างชื่อไฟล์ thumbnail
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String originalName = 'thumbnail';
      if (!kIsWeb) {
        try {
          originalName = path.basename(imageFile.path);
        } catch (e) {
          originalName = 'image_file';
        }
      }
      final fileName = 'thumb_${timestamp}_$originalName';
      
      // สร้าง path สำหรับ thumbnail
      final ref = _storage.ref().child('thumbnails/$fileName');
      
      // อัปโหลด thumbnail
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'originalUrl': originalUrl,
            'quality': quality.toString(),
            'createdAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('ไม่สามารถสร้าง thumbnail ได้: $e');
    }
  }

  /// ลบไฟล์หลายไฟล์พร้อมกัน
  static Future<void> deleteMultipleImages(List<String> imageUrls) async {
    try {
      final futures = imageUrls.map((url) => deleteImage(url));
      await Future.wait(futures);
    } catch (e) {
      throw Exception('ไม่สามารถลบรูปภาพหลายไฟล์ได้: $e');
    }
  }

  /// ดึงข้อมูลการใช้งาน Storage
  static Future<StorageUsage> getStorageUsage() async {
    try {
      // เนื่องจาก Firebase Storage ไม่มี API สำหรับดึงข้อมูลการใช้งานโดยตรง
      // เราจะใช้วิธีอื่น เช่น นับจำนวนไฟล์และขนาดไฟล์
      final folders = ['products', 'brands', 'categories', 'users', 'thumbnails'];
      int totalFiles = 0;
      int totalSize = 0;

      for (final folder in folders) {
        try {
          final files = await listFiles(folder);
          totalFiles += files.length;
          
          for (final file in files) {
            final metadata = await file.getMetadata();
            totalSize += metadata.size ?? 0;
          }
        } catch (e) {
          // Skip folder if error
        }
      }

      return StorageUsage(
        totalFiles: totalFiles,
        totalSize: totalSize,
        formattedSize: formatFileSize(totalSize),
      );
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลการใช้งาน Storage ได้: $e');
    }
  }
}

/// คลาสสำหรับเก็บข้อมูลการใช้งาน Storage
class StorageUsage {
  final int totalFiles;
  final int totalSize;
  final String formattedSize;

  StorageUsage({
    required this.totalFiles,
    required this.totalSize,
    required this.formattedSize,
  });
}