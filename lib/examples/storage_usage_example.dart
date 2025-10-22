import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// ตัวอย่างการใช้งาน Firebase Storage Service
class StorageUsageExample extends StatefulWidget {
  const StorageUsageExample({super.key});

  @override
  State<StorageUsageExample> createState() => _StorageUsageExampleState();
}

class _StorageUsageExampleState extends State<StorageUsageExample> {
  File? _selectedImage;
  String? _uploadedUrl;
  bool _isUploading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // แสดงรูปภาพที่เลือก
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildImagePreview(),
            ),
            const SizedBox(height: 16),

            // ปุ่มเลือกรูปภาพ
            ElevatedButton.icon(
              onPressed: _selectImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('เลือกรูปภาพ'),
            ),
            const SizedBox(height: 16),

            // ปุ่มอัปโหลด
            if (_selectedImage != null)
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isUploading ? 'กำลังอัปโหลด...' : 'อัปโหลดไป Firebase Storage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            const SizedBox(height: 16),

            // แสดง URL ที่อัปโหลด
            if (_uploadedUrl != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'อัปโหลดสำเร็จ!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _uploadedUrl!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

            // แสดง Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 16),

            // ตัวอย่างการใช้งานอื่นๆ
            const Text(
              'ตัวอย่างการใช้งาน:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ปุ่มทดสอบฟังก์ชันต่างๆ
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _testFileValidation,
                  child: const Text('ทดสอบ File Validation'),
                ),
                ElevatedButton(
                  onPressed: _testStorageUsage,
                  child: const Text('ดู Storage Usage'),
                ),
                ElevatedButton(
                  onPressed: _testDeleteImage,
                  child: const Text('ลบรูปภาพ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb 
          ? const Center(
              child: Text('Web: รูปภาพที่เลือก'),
            )
          : Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('ยังไม่ได้เลือกรูปภาพ'),
          ],
        ),
      );
    }
  }

  Future<void> _selectImage() async {
    try {
      // ใช้ image_picker เพื่อเลือกรูปภาพ
      // ในตัวอย่างนี้จะใช้ File แบบจำลอง
      // ในแอปจริงจะใช้ ImagePicker
      
      // สร้างไฟล์จำลองสำหรับทดสอบ
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_image.jpg');
      
      // สร้างไฟล์ว่างเพื่อทดสอบ
      await tempFile.writeAsBytes([]);
      
      setState(() {
        _selectedImage = tempFile;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      // ตรวจสอบไฟล์ก่อนอัปโหลด
      if (!StorageService.isAllowedImageType(_selectedImage!.path)) {
        throw Exception('ประเภทไฟล์ไม่รองรับ');
      }

      if (kIsWeb) {
        // สำหรับ Web platform ให้ตรวจสอบผ่าน bytes
        // (ในตัวอย่างนี้จะข้ามการตรวจสอบ)
      } else {
        if (!StorageService.isValidFileSize(_selectedImage!)) {
          throw Exception('ขนาดไฟล์ใหญ่เกินไป');
        }
      }

      // อัปโหลดไป Firebase Storage
      final downloadUrl = await StorageService.uploadProductImage(
        _selectedImage!,
        productId: 'example_product_${DateTime.now().millisecondsSinceEpoch}',
      );

      setState(() {
        _uploadedUrl = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปโหลดสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _testFileValidation() async {
    if (_selectedImage == null) {
      _showMessage('กรุณาเลือกรูปภาพก่อน');
      return;
    }

    final file = _selectedImage!;
    
    // ทดสอบการตรวจสอบไฟล์
    final isValidType = StorageService.isAllowedImageType(file.path);
    final isValidSize = StorageService.isValidFileSize(file);
    final isFirebaseUrl = StorageService.isFirebaseStorageUrl(file.path);
    
    _showMessage(
      'ผลการตรวจสอบ:\n'
      'ประเภทไฟล์: ${isValidType ? "ถูกต้อง" : "ไม่ถูกต้อง"}\n'
      'ขนาดไฟล์: ${isValidSize ? "ถูกต้อง" : "ใหญ่เกินไป"}\n'
      'Firebase URL: ${isFirebaseUrl ? "ใช่" : "ไม่ใช่"}',
    );
  }

  Future<void> _testStorageUsage() async {
    try {
      final usage = await StorageService.getStorageUsage();
      
      _showMessage(
        'ข้อมูลการใช้งาน Storage:\n'
        'จำนวนไฟล์: ${usage.totalFiles}\n'
        'ขนาดรวม: ${usage.formattedSize}',
      );
    } catch (e) {
      _showMessage('ไม่สามารถดึงข้อมูลได้: $e');
    }
  }

  Future<void> _testDeleteImage() async {
    if (_uploadedUrl == null) {
      _showMessage('ไม่มีรูปภาพที่อัปโหลดแล้ว');
      return;
    }

    try {
      await StorageService.deleteImage(_uploadedUrl!);
      
      setState(() {
        _uploadedUrl = null;
      });

      _showMessage('ลบรูปภาพสำเร็จ!');
    } catch (e) {
      _showMessage('ไม่สามารถลบรูปภาพได้: $e');
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ผลลัพธ์'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}

/// ตัวอย่างการใช้งาน Storage Service ในหน้า Admin
class AdminStorageExample extends StatelessWidget {
  const AdminStorageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Storage Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // สถิติการใช้งาน Storage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Storage Usage',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder(
                      future: StorageService.getStorageUsage(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        
                        final usage = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('จำนวนไฟล์: ${usage.totalFiles}'),
                            Text('ขนาดรวม: ${usage.formattedSize}'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ปุ่มจัดการไฟล์
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showFileList(context, 'products'),
                  icon: const Icon(Icons.inventory),
                  label: const Text('รายการรูปสินค้า'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFileList(context, 'brands'),
                  icon: const Icon(Icons.business),
                  label: const Text('รายการโลโก้แบรนด์'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFileList(context, 'categories'),
                  icon: const Icon(Icons.category),
                  label: const Text('รายการรูปหมวดหมู่'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFileList(BuildContext context, String folderPath) async {
    try {
      final files = await StorageService.listFiles(folderPath);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('ไฟล์ในโฟลเดอร์ $folderPath'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  title: Text(file.name),
                  subtitle: Text(file.fullPath),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFile(context, file.fullPath),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFile(BuildContext context, String filePath) async {
    try {
      await StorageService.deleteImage(filePath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบไฟล์สำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถลบไฟล์ได้: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


