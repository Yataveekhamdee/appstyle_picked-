/// การทดสอบการตรวจสอบประเภทไฟล์
/// 
/// ไฟล์นี้ใช้สำหรับทดสอบการทำงานของ file validation
/// เพื่อแก้ไขปัญหา "ประเภทไฟล์ไม่รองรับ"

import 'package:path/path.dart' as path;

void testFileValidation() {
  print('=== Testing File Validation ===');
  
  // ตัวอย่างไฟล์ที่ควรผ่าน
  final validFiles = [
    'image.jpg',
    'photo.jpeg', 
    'picture.png',
    'graphic.gif',
    'web_image.webp',
    '/path/to/image.jpg',
    'C:\\Users\\image.jpeg',
    'file with spaces.png',
    'IMAGE.JPG', // uppercase
    'Photo.JPEG', // mixed case
  ];
  
  // ตัวอย่างไฟล์ที่ควรไม่ผ่าน
  final invalidFiles = [
    'document.pdf',
    'text.txt',
    'video.mp4',
    'audio.mp3',
    'archive.zip',
    'image', // ไม่มี extension
    'image.bmp', // ไม่รองรับ
    'image.tiff', // ไม่รองรับ
  ];
  
  print('\n--- Testing Valid Files ---');
  for (final file in validFiles) {
    final isValid = _isAllowedImageType(file);
    print('$file: ${isValid ? "✅ PASS" : "❌ FAIL"}');
  }
  
  print('\n--- Testing Invalid Files ---');
  for (final file in invalidFiles) {
    final isValid = _isAllowedImageType(file);
    print('$file: ${isValid ? "❌ FAIL (should be invalid)" : "✅ PASS (correctly invalid)"}');
  }
  
  print('\n=== Test Complete ===');
}

/// ฟังก์ชันทดสอบการตรวจสอบประเภทไฟล์
bool _isAllowedImageType(String filePath) {
  if (filePath.isEmpty) return false;
  
  final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
  
  // ตรวจสอบ extension จาก path
  final extension = path.extension(filePath).toLowerCase();
  
  // ตรวจสอบจากชื่อไฟล์โดยตรง
  final fileName = path.basename(filePath).toLowerCase();
  
  // ตรวจสอบจากส่วนท้ายของ path
  final pathLower = filePath.toLowerCase();
  final hasValidExtension = allowedExtensions.any((ext) => 
    extension == ext || 
    fileName.endsWith(ext) || 
    pathLower.endsWith(ext)
  );
  
  return hasValidExtension;
}

/// ฟังก์ชันทดสอบแบบ alternative
bool _isAllowedImageTypeAlternative(String fileName) {
  final nameLower = fileName.toLowerCase();
  return nameLower.endsWith('.jpg') || 
         nameLower.endsWith('.jpeg') || 
         nameLower.endsWith('.png') || 
         nameLower.endsWith('.gif') || 
         nameLower.endsWith('.webp');
}

/// ตัวอย่างการใช้งาน
void main() {
  testFileValidation();
  
  // ทดสอบไฟล์เฉพาะ
  print('\n--- Testing Specific Cases ---');
  final testCases = [
    'image.jpg',
    'photo.jpeg',
    'picture.png',
    'document.pdf',
    'image', // ไม่มี extension
  ];
  
  for (final testCase in testCases) {
    final method1 = _isAllowedImageType(testCase);
    final method2 = _isAllowedImageTypeAlternative(testCase);
    print('$testCase: Method1=$method1, Method2=$method2');
  }
}





