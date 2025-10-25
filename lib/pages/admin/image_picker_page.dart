// lib/pages/admin/image_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../services/storage_service.dart';

class ImagePickerPage extends StatefulWidget {
  final String? initialImage; // ใช้โชว์รูปเดิมถ้ามี
  const ImagePickerPage({super.key, this.initialImage});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final _picker = ImagePicker();

  XFile? _picked;         // ไฟล์ที่เลือก (ทั้งมือถือและเว็บ)
  Uint8List? _previewBytes; // bytes ที่ใช้พรีวิวทันที
  String? _uploadedUrl;   // URL หลังอัปโหลดเสร็จ
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    // กล่องพรีวิวกรอบโค้ง
    Widget _previewBox(Widget child) => Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: child,
          ),
        );

    // ---------- เลือกว่าจะโชว์อะไรในพรีวิว ----------
    Widget preview;
    if (_previewBytes != null) {
      // เรามี bytes จากรูปที่เพิ่งเลือก
      preview = Image.memory(
        _previewBytes!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const _LoadError(),
      );
    } else if ((_uploadedUrl ?? '').isNotEmpty) {
      // อัปโหลดเสร็จแล้ว มี URL ถาวรจาก Firebase
      preview = Image.network(
        _uploadedUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const _LoadError(),
      );
    } else if ((widget.initialImage ?? '').isNotEmpty) {
      // ตอนเปิดหน้านี้ครั้งแรก เคยมีรูปเดิม?
      preview = Image.network(
        widget.initialImage!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const _LoadError(),
      );
    } else {
      preview = const _EmptyPreview();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกรูปภาพ'),
        actions: [
          if ((_uploadedUrl ?? '').isNotEmpty)
            TextButton(
              onPressed: _confirm,
              child: const Text('ยืนยัน'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _previewBox(preview)),

          // ปุ่มคำสั่งด้านล่าง
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ปุ่มเลือกจากแกลเลอรี่ / เลือกรูปจากเครื่อง (เว็บ)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('เลือกจากแกลเลอรี่'),
                  ),
                ),
                const SizedBox(height: 12),

                // ปุ่มอัปโหลดขึ้น Firebase
                if (_picked != null && _previewBytes != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _upload,
                      icon: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        _busy
                            ? 'กำลังอัปโหลด...'
                            : 'อัปโหลดไป Firebase Storage',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- เลือกรูป ----------
  Future<void> _pickFromGallery() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (x == null) return; // ผู้ใช้กดยกเลิก

      // อ่าน bytes ของรูป (ทำงานได้ทั้ง Mobile และ Web)
      final bytes = await x.readAsBytes();

      setState(() {
        _picked = x;
        _previewBytes = bytes; // เก็บไว้โชว์ preview ทันที
        _uploadedUrl = null;   // reset ของเก่า (เพราะเราเลือกไฟล์ใหม่)
      });
    } catch (e) {
      _toast('เกิดข้อผิดพลาดตอนเลือกรูป: $e', isError: true);
    }
  }

  //อัปโหลดรูปขึ้น Firebase 
  Future<void> _upload() async {
    if (_picked == null || _previewBytes == null) {
      _toast('ยังไม่ได้เลือกรูปเลย', isError: true);
      return;
    }

    setState(() => _busy = true);
    try {
      // อัปโหลดด้วย bytes -> ปลอดภัยทุกแพลตฟอร์ม (Android / iOS / Web)
      final url = await StorageService.uploadProductImageBytes(_previewBytes!);

      setState(() {
        _uploadedUrl = url; // เก็บ URL ที่ได้จาก Firebase Storage
        _picked = null;     // ล้าง state ไฟล์ชั่วคราว
        _previewBytes = null;
      });

      _toast('อัปโหลดสำเร็จ!');
    } catch (e) {
      _toast('อัปโหลดไม่สำเร็จ: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---------- ส่ง URL กลับหน้าเดิม ----------
  void _confirm() {
    if ((_uploadedUrl ?? '').isNotEmpty) {
      Navigator.pop(context, _uploadedUrl);
    }
  }

  // ---------- Toast ----------
  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}

// ---------- Widgets ย่อย ----------
class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();
  @override
  Widget build(BuildContext context) {
    return const Center(
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
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline),
          SizedBox(height: 8),
          Text('โหลดรูปไม่สำเร็จ'),
        ],
      ),
    );
  }
}
