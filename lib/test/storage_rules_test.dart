import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/storage_service.dart';

/// คลาสสำหรับทดสอบ Firebase Storage Security Rules
class StorageRulesTest {
  static final _storage = FirebaseStorage.instance;
  static final _auth = FirebaseAuth.instance;

  /// ทดสอบการอัปโหลดรูปภาพสินค้า (Admin)
  static Future<void> testProductUploadAsAdmin() async {
    print('🧪 ทดสอบ: อัปโหลดรูปภาพสินค้า (Admin)');
    
    try {
      // Login as admin
      await _auth.signInWithEmailAndPassword(
        email: 'admin@gmail.com',
        password: 'admin123', // เปลี่ยนเป็น password จริง
      );

      // สร้างไฟล์ทดสอบ
      final testFile = await _createTestImageFile('product_test.jpg');
      
      // อัปโหลดรูปภาพสินค้า
      final downloadUrl = await StorageService.uploadProductImage(
        testFile,
        productId: 'test_product_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('✅ อัปโหลดรูปภาพสินค้า (Admin): สำเร็จ');
      print('   URL: $downloadUrl');
      
      // ลบไฟล์ทดสอบ
      await StorageService.deleteImage(downloadUrl);
      print('✅ ลบไฟล์ทดสอบ: สำเร็จ');
      
    } catch (e) {
      print('❌ อัปโหลดรูปภาพสินค้า (Admin): ไม่สำเร็จ - $e');
    }
  }

  /// ทดสอบการอัปโหลดรูปภาพสินค้า (User ทั่วไป)
  static Future<void> testProductUploadAsUser() async {
    print('🧪 ทดสอบ: อัปโหลดรูปภาพสินค้า (User)');
    
    try {
      // Login as regular user
      await _auth.signInWithEmailAndPassword(
        email: 'user@gmail.com',
        password: 'user123', // เปลี่ยนเป็น password จริง
      );

      // สร้างไฟล์ทดสอบ
      final testFile = await _createTestImageFile('product_test_user.jpg');
      
      // พยายามอัปโหลดรูปภาพสินค้า (ควรไม่สำเร็จ)
      await StorageService.uploadProductImage(
        testFile,
        productId: 'test_product_user_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('❌ อัปโหลดรูปภาพสินค้า (User): ไม่ควรสำเร็จ แต่สำเร็จ');
      
    } catch (e) {
      print('✅ อัปโหลดรูปภาพสินค้า (User): ไม่สำเร็จ (ตามที่คาดหวัง) - $e');
    }
  }

  /// ทดสอบการอัปโหลดรูปภาพผู้ใช้
  static Future<void> testUserImageUpload() async {
    print('🧪 ทดสอบ: อัปโหลดรูปภาพผู้ใช้');
    
    try {
      // Login as regular user
      await _auth.signInWithEmailAndPassword(
        email: 'user@gmail.com',
        password: 'user123',
      );

      final userId = _auth.currentUser?.uid ?? 'test_user';
      
      // สร้างไฟล์ทดสอบ
      final testFile = await _createTestImageFile('user_test.jpg');
      
      // อัปโหลดรูปภาพผู้ใช้
      final downloadUrl = await StorageService.uploadUserImage(
        testFile,
        userId: userId,
      );

      print('✅ อัปโหลดรูปภาพผู้ใช้: สำเร็จ');
      print('   URL: $downloadUrl');
      
      // ลบไฟล์ทดสอบ
      await StorageService.deleteImage(downloadUrl);
      print('✅ ลบไฟล์ทดสอบ: สำเร็จ');
      
    } catch (e) {
      print('❌ อัปโหลดรูปภาพผู้ใช้: ไม่สำเร็จ - $e');
    }
  }

  /// ทดสอบการอ่านรูปภาพ (ไม่ Login)
  static Future<void> testReadImageWithoutAuth() async {
    print('🧪 ทดสอบ: อ่านรูปภาพ (ไม่ Login)');
    
    try {
      // Sign out first
      await _auth.signOut();

      // พยายามอ่านรูปภาพสินค้า
      final ref = _storage.ref('products/test_product.jpg');
      final downloadUrl = await ref.getDownloadURL();

      print('✅ อ่านรูปภาพ (ไม่ Login): สำเร็จ');
      print('   URL: $downloadUrl');
      
    } catch (e) {
      if (e.toString().contains('object-not-found')) {
        print('⚠️ อ่านรูปภาพ (ไม่ Login): ไม่พบไฟล์ (ปกติ)');
      } else {
        print('❌ อ่านรูปภาพ (ไม่ Login): ไม่สำเร็จ - $e');
      }
    }
  }

  /// ทดสอบการอัปโหลดไฟล์ประเภทไม่ถูกต้อง
  static Future<void> testInvalidFileType() async {
    print('🧪 ทดสอบ: อัปโหลดไฟล์ประเภทไม่ถูกต้อง');
    
    try {
      // Login as admin
      await _auth.signInWithEmailAndPassword(
        email: 'admin@gmail.com',
        password: 'admin123',
      );

      // สร้างไฟล์ที่ไม่ใช่รูปภาพ
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test.txt');
      await testFile.writeAsString('This is not an image');

      // พยายามอัปโหลดไฟล์ที่ไม่ใช่รูปภาพ
      final ref = _storage.ref('products/test_file.txt');
      await ref.putFile(testFile);

      print('❌ อัปโหลดไฟล์ประเภทไม่ถูกต้อง: ไม่ควรสำเร็จ แต่สำเร็จ');
      
      // ลบไฟล์ทดสอบ
      await testFile.delete();
      
    } catch (e) {
      print('✅ อัปโหลดไฟล์ประเภทไม่ถูกต้อง: ไม่สำเร็จ (ตามที่คาดหวัง) - $e');
    }
  }

  /// ทดสอบการอัปโหลดไฟล์ขนาดใหญ่เกินไป
  static Future<void> testFileTooLarge() async {
    print('🧪 ทดสอบ: อัปโหลดไฟล์ขนาดใหญ่เกินไป');
    
    try {
      // Login as admin
      await _auth.signInWithEmailAndPassword(
        email: 'admin@gmail.com',
        password: 'admin123',
      );

      // สร้างไฟล์ขนาดใหญ่ (จำลอง)
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/large_file.jpg');
      
      // สร้างไฟล์ขนาด 15MB (เกิน 10MB limit)
      final largeData = List.generate(15 * 1024 * 1024, (index) => 0);
      await testFile.writeAsBytes(largeData);

      // พยายามอัปโหลดไฟล์ขนาดใหญ่
      final ref = _storage.ref('products/large_file.jpg');
      await ref.putFile(testFile);

      print('❌ อัปโหลดไฟล์ขนาดใหญ่: ไม่ควรสำเร็จ แต่สำเร็จ');
      
      // ลบไฟล์ทดสอบ
      await testFile.delete();
      
    } catch (e) {
      print('✅ อัปโหลดไฟล์ขนาดใหญ่: ไม่สำเร็จ (ตามที่คาดหวัง) - $e');
    }
  }

  /// ทดสอบการลบไฟล์ของผู้อื่น
  static Future<void> testDeleteOtherUserFile() async {
    print('🧪 ทดสอบ: ลบไฟล์ของผู้อื่น');
    
    try {
      // Login as regular user
      await _auth.signInWithEmailAndPassword(
        email: 'user@gmail.com',
        password: 'user123',
      );

      // พยายามลบไฟล์ของผู้อื่น (ควรไม่สำเร็จ)
      final ref = _storage.ref('users/other_user_1234567890123.jpg');
      await ref.delete();

      print('❌ ลบไฟล์ของผู้อื่น: ไม่ควรสำเร็จ แต่สำเร็จ');
      
    } catch (e) {
      print('✅ ลบไฟล์ของผู้อื่น: ไม่สำเร็จ (ตามที่คาดหวัง) - $e');
    }
  }

  /// ทดสอบการอัปโหลดไปโฟลเดอร์ที่ไม่ได้รับอนุญาต
  static Future<void> testUploadToUnauthorizedFolder() async {
    print('🧪 ทดสอบ: อัปโหลดไปโฟลเดอร์ที่ไม่ได้รับอนุญาต');
    
    try {
      // Login as regular user
      await _auth.signInWithEmailAndPassword(
        email: 'user@gmail.com',
        password: 'user123',
      );

      // สร้างไฟล์ทดสอบ
      final testFile = await _createTestImageFile('unauthorized_test.jpg');

      // พยายามอัปโหลดไปโฟลเดอร์ที่ไม่ได้รับอนุญาต
      final ref = _storage.ref('unauthorized_folder/test.jpg');
      await ref.putFile(testFile);

      print('❌ อัปโหลดไปโฟลเดอร์ที่ไม่ได้รับอนุญาต: ไม่ควรสำเร็จ แต่สำเร็จ');
      
    } catch (e) {
      print('✅ อัปโหลดไปโฟลเดอร์ที่ไม่ได้รับอนุญาต: ไม่สำเร็จ (ตามที่คาดหวัง) - $e');
    }
  }

  /// ทดสอบการอัปโหลดไฟล์ที่ไม่มี timestamp
  static Future<void> testUploadWithoutTimestamp() async {
    print('🧪 ทดสอบ: อัปโหลดไฟล์ที่ไม่มี timestamp');
    
    try {
      // Login as admin
      await _auth.signInWithEmailAndPassword(
        email: 'admin@gmail.com',
        password: 'admin123',
      );

      // สร้างไฟล์ทดสอบ
      final testFile = await _createTestImageFile('no_timestamp.jpg');

      // พยายามอัปโหลดไฟล์ที่ไม่มี timestamp
      final ref = _storage.ref('products/product_without_timestamp.jpg');
      await ref.putFile(testFile);

      print('❌ อัปโหลดไฟล์ที่ไม่มี timestamp: ไม่ควรสำเร็จ แต่สำเร็จ');
      
    } catch (e) {
      print('✅ อัปโหลดไฟล์ที่ไม่มี timestamp: ไม่สำเร็จ (ตามที่คาดหวัง) - $e');
    }
  }

  /// รันการทดสอบทั้งหมด
  static Future<void> runAllTests() async {
    print('🚀 เริ่มการทดสอบ Firebase Storage Security Rules');
    print('=' * 60);

    try {
      await testProductUploadAsAdmin();
      print('');
      
      await testProductUploadAsUser();
      print('');
      
      await testUserImageUpload();
      print('');
      
      await testReadImageWithoutAuth();
      print('');
      
      await testInvalidFileType();
      print('');
      
      await testFileTooLarge();
      print('');
      
      await testDeleteOtherUserFile();
      print('');
      
      await testUploadToUnauthorizedFolder();
      print('');
      
      await testUploadWithoutTimestamp();
      print('');
      
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการทดสอบ: $e');
    }

    print('=' * 60);
    print('🏁 การทดสอบเสร็จสิ้น');
    
    // Sign out
    await _auth.signOut();
  }

  /// สร้างไฟล์รูปภาพทดสอบ
  static Future<File> _createTestImageFile(String fileName) async {
    final tempDir = Directory.systemTemp;
    final testFile = File('${tempDir.path}/$fileName');
    
    // สร้างไฟล์ JPEG แบบง่าย (1x1 pixel)
    final jpegHeader = [
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
      0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
      0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
      0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
      0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x01,
      0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
      0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0xFF, 0xC4,
      0x00, 0x14, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x0C,
      0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3F, 0x00, 0x80, 0xFF, 0xD9
    ];
    
    await testFile.writeAsBytes(jpegHeader);
    return testFile;
  }
}

/// Widget สำหรับทดสอบ Rules ในแอป
class StorageRulesTestWidget extends StatefulWidget {
  const StorageRulesTestWidget({super.key});

  @override
  State<StorageRulesTestWidget> createState() => _StorageRulesTestWidgetState();
}

class _StorageRulesTestWidgetState extends State<StorageRulesTestWidget> {
  bool _isRunning = false;
  String _output = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Rules Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isRunning ? null : _runTests,
              child: _isRunning
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('กำลังทดสอบ...'),
                      ],
                    )
                  : const Text('รันการทดสอบทั้งหมด'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _output = '';
    });

    // Capture output
    final originalOutput = _output;
    
    try {
      await StorageRulesTest.runAllTests();
    } catch (e) {
      setState(() {
        _output = '$originalOutput\n❌ เกิดข้อผิดพลาด: $e';
      });
    }

    setState(() {
      _isRunning = false;
    });
  }
}






