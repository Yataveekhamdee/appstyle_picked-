// lib/pages/admin/image_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../services/storage_service.dart';

class ImagePickerPage extends StatefulWidget {
  final String? initialImage;
  const ImagePickerPage({super.key, this.initialImage});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final _picker = ImagePicker();
  XFile? _picked; // ไฟล์ที่เลือก (มือถือ)
  Uint8List? _webBytes; // ไฟล์ที่เลือก (เว็บ)
  String? _uploadedUrl; // URL หลังอัปโหลด
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    // ----- ตัวช่วยพรีวิวแบบสั้น -----
    Widget _previewBox(Widget child) => Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child:
              ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
        );

    Widget preview;
    if (_picked != null) {
      preview = kIsWeb && _webBytes != null
          ? Image.memory(_webBytes!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const _LoadError())
          : Image.file(File(_picked!.path),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const _LoadError());
    } else if ((_uploadedUrl ?? '').isNotEmpty) {
      preview = Image.network(_uploadedUrl!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const _LoadError());
    } else if ((widget.initialImage ?? '').isNotEmpty) {
      preview = Image.network(widget.initialImage!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const _LoadError());
    } else {
      preview = const _EmptyPreview();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกรูปภาพ'),
        actions: [
          if ((_uploadedUrl ?? '').isNotEmpty)
            TextButton(onPressed: _confirm, child: const Text('ยืนยัน')),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _previewBox(preview)),

          // ปุ่มคำสั่ง
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _pickFromGallery,
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
            ]),
          ),
        ],
      ),
    );
  }

  // ----- Actions -----
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
        _webBytes = await x.readAsBytes();
      } else {
        _webBytes = null;
      }
      setState(() {
        _picked = x;
        _uploadedUrl = null;
      });
    } catch (e) {
      _toast('เกิดข้อผิดพลาด: $e', isError: true);
    }
  }

  Future<void> _upload() async {
    if (_picked == null) return;
    setState(() => _busy = true);
    try {
      final url = kIsWeb
          ? await StorageService.uploadProductImageBytes(_webBytes!)
          : await StorageService.uploadProductImage(File(_picked!.path));

      setState(() {
        _uploadedUrl = url;
        _picked = null;
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
    if ((_uploadedUrl ?? '').isNotEmpty) Navigator.pop(context, _uploadedUrl);
  }

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), backgroundColor: isError ? Colors.red : null),
    );
  }
}

// ===== Widgets ย่อยเล็ก ๆ เพื่อความอ่านง่าย =====
class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.image, size: 64),
          SizedBox(height: 8),
          Text('ยังไม่ได้เลือกรูปภาพ'),
          Text('กดปุ่ม “เลือกจากแกลเลอรี่” ด้านล่าง'),
        ]),
      );
}

class _LoadError extends StatelessWidget {
  const _LoadError();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline),
          SizedBox(height: 8),
          Text('โหลดรูปไม่สำเร็จ'),
        ]),
      );
}
