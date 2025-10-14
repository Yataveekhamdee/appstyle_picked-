import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../services/storage_service.dart';
import '../../widgets/simple_network_image_widget.dart';

class ImagePickerPage extends StatefulWidget {
  final String? initialImage;
  
  const ImagePickerPage({super.key, this.initialImage});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกรูปภาพ', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_selectedImage != null || _imageUrl != null)
            TextButton(
              onPressed: _confirmSelection,
              child: const Text('ยืนยัน', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          // แสดงรูปภาพที่เลือก
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _buildImagePreview(),
            ),
          ),

          // ปุ่มเลือกรูปภาพ
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('เลือกรูปจากแกลเลอรี่'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('ถ่ายรูป'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // ปุ่มอัปโหลดไป Firebase Storage
                if (_selectedImage != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadToFirebase,
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (_selectedImage != null) const SizedBox(height: 12),
                
                // ฟิลด์ URL รูปภาพ
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _imageUrl = value.trim().isEmpty ? null : value.trim();
                      _selectedImage = null; // เคลียร์รูปที่เลือก
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'หรือใส่ URL รูปภาพ',
                    hintText: 'https://example.com/image.jpg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildImageWidget(),
      );
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return SimpleSmartImageWidget(
        imageUrl: _imageUrl!,
        fit: BoxFit.contain,
        borderRadius: BorderRadius.circular(12),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ยังไม่ได้เลือกรูปภาพ',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              'เลือกรูปจากแกลเลอรี่ ถ่ายรูป หรือใส่ URL',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  /// สร้าง Image Widget ที่รองรับทั้ง Mobile และ Web
  Widget _buildImageWidget() {
    if (kIsWeb) {
      // สำหรับ Web platform
      if (_webImageBytes != null) {
        return Image.memory(
          _webImageBytes!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 8),
                  Text('ไม่สามารถโหลดรูปภาพได้'),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('ยังไม่ได้เลือกรูปภาพ'),
              ],
            ),
          ),
        );
      }
    } else {
      // สำหรับ Mobile platform
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red),
                SizedBox(height: 8),
                Text('ไม่สามารถโหลดรูปภาพได้'),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imageUrl = null; // เคลียร์ URL เมื่อเลือกรูปใหม่
        });

        // สำหรับ Web platform ให้โหลด bytes
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadToFirebase() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      File? file;
      
      if (kIsWeb) {
        // สำหรับ Web platform ใช้ bytes
        if (_webImageBytes == null) {
          throw Exception('ไม่พบข้อมูลรูปภาพ');
        }
        
        // ตรวจสอบขนาดไฟล์ (Web)
        if (_webImageBytes!.length > 10 * 1024 * 1024) {
          throw Exception('ขนาดไฟล์ใหญ่เกินไป (สูงสุด 10MB)');
        }
        
        // สร้างไฟล์ชั่วคราวสำหรับ Web
        try {
          file = File.fromRawPath(_webImageBytes!);
        } catch (e) {
          print('Debug - Error creating File from bytes: $e');
          throw Exception('ไม่สามารถสร้างไฟล์จากข้อมูลรูปภาพได้: $e');
        }
      } else {
        // สำหรับ Mobile platform
        file = File(_selectedImage!.path);
        
        // ตรวจสอบขนาดไฟล์
        if (!StorageService.isValidFileSize(file)) {
          throw Exception('ขนาดไฟล์ใหญ่เกินไป (สูงสุด 10MB)');
        }
      }

      // ตรวจสอบประเภทไฟล์
      final filePath = _selectedImage!.path;
      final fileName = _selectedImage!.name;
      
      // Debug information
      print('Debug - File Path: $filePath');
      print('Debug - File Name: $fileName');
      print('Debug - Extension: ${filePath.split('.').last.toLowerCase()}');
      
      // ตรวจสอบประเภทไฟล์แบบหลายวิธี
      bool isValidType = StorageService.isAllowedImageType(filePath);
      
      // ถ้าไม่ผ่าน ให้ลองตรวจสอบจากชื่อไฟล์โดยตรง
      if (!isValidType) {
        final nameLower = fileName.toLowerCase();
        isValidType = nameLower.endsWith('.jpg') || 
                     nameLower.endsWith('.jpeg') || 
                     nameLower.endsWith('.png') || 
                     nameLower.endsWith('.gif') || 
                     nameLower.endsWith('.webp');
        print('Debug - Fallback validation: $isValidType');
      }
      
      if (!isValidType) {
        throw Exception('ประเภทไฟล์ไม่รองรับ (รองรับ: JPG, PNG, GIF, WebP)\n'
            'ไฟล์ที่เลือก: $fileName\n'
            'Path: $filePath\n'
            'Extension: ${filePath.split('.').last.toLowerCase()}');
      }

      // อัปโหลดไป Firebase Storage
      String downloadUrl;
      if (kIsWeb && _webImageBytes != null) {
        // สำหรับ Web platform ส่ง bytes โดยตรง
        downloadUrl = await StorageService.uploadProductImageBytes(_webImageBytes!);
      } else {
        // สำหรับ Mobile platform ส่ง File
        downloadUrl = await StorageService.uploadProductImage(file);
      }

      setState(() {
        _imageUrl = downloadUrl;
        _selectedImage = null; // เคลียร์รูปที่เลือก
        _webImageBytes = null; // เคลียร์ bytes สำหรับ Web
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปโหลดรูปภาพสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _confirmSelection() {
    String? selectedImagePath;
    
    if (_selectedImage != null) {
      selectedImagePath = _selectedImage!.path;
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      selectedImagePath = _imageUrl!;
    }

    if (selectedImagePath != null) {
      Navigator.pop(context, selectedImagePath);
    }
  }
}
