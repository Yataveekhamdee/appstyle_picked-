// lib/account_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _name  = TextEditingController();
  final _email = TextEditingController();
  XFile? _picked; // รูปที่เลือก/ถ่าย

  @override
  void didChangeDependencies() {
    // รองรับรับค่าเริ่มต้นจาก arguments: {'name':..., 'email':..., 'avatarPath':...}
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _name.text  = (args['name']  ?? '').toString();
      _email.text = (args['email'] ?? '').toString();
      final path = args['avatarPath'] as String?;
      if (path != null && path.isNotEmpty) _picked = XFile(path);
      setState(() {});
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource src) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: src, imageQuality: 85);
    if (img != null) setState(() => _picked = img);
  }

  void _save() {
    Navigator.pop(context, {
      'name'      : _name.text.trim(),
      'email'     : _email.text.trim(),
      'avatarPath': _picked?.path,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกโปรไฟล์แล้ว')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ImageProvider? avatar = (_picked != null)
        ? FileImage(File(_picked!.path))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('บัญชีผู้ใช้'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFF0F0F0),
                  backgroundImage: avatar,
                  child: avatar == null
                      ? const Icon(Icons.person, size: 44, color: Colors.black54)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: () => _pick(ImageSource.gallery),
                    borderRadius: BorderRadius.circular(999),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: cs.primary,
                      child: const Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Name
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: 'ชื่อผู้ใช้',
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 1.6),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Email
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'อีเมล',
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 1.6),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Actions
          ElevatedButton(
            onPressed: _save,
            child: const Text('บันทึกโปรไฟล์', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _pick(ImageSource.camera),
            icon: const Icon(Icons.photo_camera),
            label: const Text('ถ่ายรูปโปรไฟล์'),
          ),
        ],
      ),
    );
  }
}

