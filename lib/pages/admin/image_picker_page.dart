// lib/pages/admin/image_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../services/storage_service.dart';

class ImagePickerPage extends StatefulWidget {
  final String? initialImage; // ยังรับไว้เผื่อส่งค่ามาแสดงพรีวิวได้
  const ImagePickerPage({super.key, this.initialImage});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final _picker = ImagePicker();

  XFile? _picked; // ไฟล์ที่เลือก (มือถือ)
  Uint8List? _webBytes; // ไฟล์ที่เลือก (เว็บ)
  String? _uploadedUrl; // URL หลังอัปโหลดสำเร็จ
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // ถ้ามี initialImage จะพรีวิวให้ แต่จะไม่ใช้เป็นผลลัพธ์จนกว่าจะอัปโหลดใหม่
  }

  @override
  Widget build(BuildContext context) {
    final hasSomething = _picked != null ||
        _uploadedUrl != null ||
        (widget.initialImage?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกรูปภาพ'),
        actions: [
          if (_uploadedUrl != null && _uploadedUrl!.isNotEmpty)
            TextButton(onPressed: _confirm, child: const Text('ยืนยัน')),
        ],
      ),
      body: Column(
        children: [
          // พรีวิว
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: hasSomething ? _buildPreview() : _emptyPreview(),
            ),
          ),

          // ปุ่มเลือกจากแกลเลอรี่ + อัปโหลด
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : () => _pickFromGallery(),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('เลือกจากแกลเลอรี่'),
                  ),
                ),
                const SizedBox(height: 12),
                if (_picked != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _upload,
                      icon: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cloud_upload),
                      label: Text(_busy
                          ? 'กำลังอัปโหลด...'
                          : 'อัปโหลดไป Firebase Storage'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Preview ----------
  Widget _buildPreview() {
    // ถ้าเพิ่งเลือกไฟล์ แสดงไฟล์นั้นก่อน
    if (_picked != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb && _webBytes != null
            ? Image.memory(_webBytes!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _errorPreview())
            : Image.file(File(_picked!.path),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _errorPreview()),
      );
    }

    // ถ้าอัปโหลดเสร็จแล้ว แสดงจาก URL ที่ได้
    if (_uploadedUrl != null && _uploadedUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(_uploadedUrl!,
            fit: BoxFit.contain, errorBuilder: (_, __, ___) => _errorPreview()),
      );
    }

    // ไม่ได้เลือก/อัปโหลด แต่ส่ง initialImage มา ก็พรีวิวให้เฉย ๆ
    if (widget.initialImage?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(widget.initialImage!,
            fit: BoxFit.contain, errorBuilder: (_, __, ___) => _errorPreview()),
      );
    }

    return _emptyPreview();
  }

  Widget _emptyPreview() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64),
            SizedBox(height: 8),
            Text('ยังไม่ได้เลือกรูปภาพ'),
            Text('กดปุ่ม “เลือกจากแกลเลอรี่” ด้านล่าง'),
          ],
        ),
      );

  Widget _errorPreview() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline),
            SizedBox(height: 8),
            Text('โหลดรูปไม่สำเร็จ')
          ],
        ),
      );

  // ---------- Actions ----------
  Future<void> _pickFromGallery() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (x == null) return;

      if (kIsWeb) {
        final bytes = await x.readAsBytes();
        setState(() {
          _picked = x;
          _webBytes = bytes;
          _uploadedUrl = null; // รีเซ็ตผลลัพธ์เก่า
        });
      } else {
        setState(() {
          _picked = x;
          _webBytes = null;
          _uploadedUrl = null; // รีเซ็ตผลลัพธ์เก่า
        });
      }
    } catch (e) {
      _toast('เกิดข้อผิดพลาด: $e', isError: true);
    }
  }

  Future<void> _upload() async {
    if (_picked == null) return;
    setState(() => _busy = true);
    try {
      late final String url;

      if (kIsWeb) {
        if (_webBytes == null) throw 'ไม่พบข้อมูลรูปภาพ';
        url = await StorageService.uploadProductImageBytes(_webBytes!);
      } else {
        final file = File(_picked!.path);
        url = await StorageService.uploadProductImage(file);
      }

      setState(() {
        _uploadedUrl = url; // ได้ URL กลับมา
        _picked = null; // เคลียร์ไฟล์ที่เลือกหลังอัปโหลด
        _webBytes = null;
      });
      _toast('อัปโหลดสำเร็จ!');
    } catch (e) {
      _toast('อัปโหลดไม่สำเร็จ: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _confirm() {
    if (_uploadedUrl == null || _uploadedUrl!.isEmpty) return;
    Navigator.pop(context, _uploadedUrl);
  }

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), backgroundColor: isError ? Colors.red : null),
    );
  }
}
