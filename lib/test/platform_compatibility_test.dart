/// การทดสอบ Platform Compatibility
/// 
/// ไฟล์นี้ใช้สำหรับทดสอบการทำงานของ platform-specific code
/// เพื่อแก้ไขปัญหา "Platform._operatingSystem"

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void testPlatformCompatibility() {
  print('=== Testing Platform Compatibility ===');
  
  // ทดสอบ kIsWeb detection
  print('kIsWeb: $kIsWeb');
  print('kDebugMode: $kDebugMode');
  print('Platform: ${kIsWeb ? 'Web' : 'Mobile/Desktop'}');
  
  // ทดสอบ path operations
  testPathOperations();
  
  // ทดสอบ file operations
  testFileOperations();
  
  print('\n=== Test Complete ===');
}

void testPathOperations() {
  print('\n--- Testing Path Operations ---');
  
  final testPaths = [
    '/path/to/image.jpg',
    'C:\\Users\\Documents\\image.jpeg',
    'blob:http://localhost:3000/abc123',
    'image.png',
    'folder/subfolder/image.gif',
  ];
  
  for (final testPath in testPaths) {
    print('Testing path: $testPath');
    
    // ทดสอบ extension
    try {
      final extension = path.extension(testPath).toLowerCase();
      print('  Extension: $extension');
    } catch (e) {
      print('  Extension error: $e');
    }
    
    // ทดสอบ basename
    try {
      if (kIsWeb) {
        // สำหรับ Web platform ใช้ string operations
        final fileName = testPath.split('/').last.toLowerCase();
        print('  File name (Web): $fileName');
      } else {
        // สำหรับ Mobile platform ใช้ path package
        final fileName = path.basename(testPath).toLowerCase();
        print('  File name (Mobile): $fileName');
      }
    } catch (e) {
      print('  File name error: $e');
    }
    
    // ทดสอบ validation
    final isValid = isValidImagePath(testPath);
    print('  Is valid image: $isValid');
    print('');
  }
}

void testFileOperations() {
  print('\n--- Testing File Operations ---');
  
  if (kIsWeb) {
    print('Web platform - File operations limited');
    print('Using File.fromRawPath() for Web');
  } else {
    print('Mobile/Desktop platform - Full File API support');
    
    // ทดสอบการสร้างไฟล์ชั่วคราว
    try {
      final tempFile = File('/tmp/test_image.jpg');
      print('Temp file created: ${tempFile.path}');
    } catch (e) {
      print('Temp file creation error: $e');
    }
  }
}

/// ฟังก์ชันทดสอบการตรวจสอบ path ที่เป็นรูปภาพ
bool isValidImagePath(String filePath) {
  if (filePath.isEmpty) return false;
  
  final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
  
  // ตรวจสอบ extension จาก path
  String extension = '';
  try {
    extension = path.extension(filePath).toLowerCase();
  } catch (e) {
    // สำหรับ Web platform หรือ path ที่ไม่ถูกต้อง
    final parts = filePath.split('.');
    if (parts.length > 1) {
      extension = '.${parts.last.toLowerCase()}';
    }
  }
  
  // ตรวจสอบจากชื่อไฟล์โดยตรง
  String fileName = 'unknown';
  if (kIsWeb) {
    // สำหรับ Web platform ใช้ string operations
    fileName = filePath.split('/').last.toLowerCase();
  } else {
    try {
      fileName = path.basename(filePath).toLowerCase();
    } catch (e) {
      // สำหรับ Web platform หรือ path ที่ไม่ถูกต้อง
      fileName = filePath.split('/').last.toLowerCase();
    }
  }
  
  // ตรวจสอบจากส่วนท้ายของ path
  final pathLower = filePath.toLowerCase();
  final hasValidExtension = allowedExtensions.any((ext) => 
    extension == ext || 
    fileName.endsWith(ext) || 
    pathLower.endsWith(ext)
  );
  
  return hasValidExtension;
}

/// ฟังก์ชันทดสอบการสร้างชื่อไฟล์
String generateFileName(String originalPath, {String? customName}) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  String originalName = 'image';
  if (customName != null) {
    originalName = customName;
  } else if (kIsWeb) {
    // สำหรับ Web platform
    originalName = 'web_image';
  } else {
    try {
      originalName = path.basename(originalPath);
    } catch (e) {
      originalName = 'image_file';
    }
  }
  
  return '${timestamp}_$originalName';
}

/// ตัวอย่างการใช้งาน
void main() {
  testPlatformCompatibility();
  
  // ทดสอบการสร้างชื่อไฟล์
  print('\n--- Testing File Name Generation ---');
  final testPaths = [
    '/path/to/image.jpg',
    'blob:http://localhost:3000/abc123',
    'image.png',
  ];
  
  for (final testPath in testPaths) {
    final fileName = generateFileName(testPath);
    print('$testPath -> $fileName');
  }
}