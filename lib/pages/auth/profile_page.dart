import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  String _avatarLetter(Map<String, dynamic>? data, String? email) {
    final name = (data?['name'] ?? '').toString().trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    final em = (email ?? '').trim();
    if (em.isNotEmpty) return em[0].toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() =>
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false));
      return const SizedBox.shrink();
    }

    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์ของฉัน')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data?.data() ?? {}; // ถ้า doc ยังไม่มี ให้ใช้ map ว่าง
          // เติมชื่อในช่องครั้งแรกเท่านั้น เพื่อไม่ให้เคอร์เซอร์กระตุก
          if (_name.text.isEmpty && (data['name'] ?? '').toString().isNotEmpty) {
            _name.text = data['name'];
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 40,
                child: Text(
                  _avatarLetter(data, user.email), // <-- ปลอดภัยแล้ว
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              Text('อีเมล', style: Theme.of(context).textTheme.labelMedium),
              Text(user.email ?? '-', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),

              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'ชื่อที่แสดง'),
              ),
              const SizedBox(height: 12),

              FilledButton(
                onPressed: _saving ? null : () async {
                  setState(() => _saving = true);
                  try {
                    await doc.set({'name': _name.text.trim()},
                        SetOptions(merge: true));
                    await user.updateDisplayName(_name.text.trim());
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('บันทึกแล้ว')),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('บันทึก'),
              ),
              const SizedBox(height: 24),

              OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  }
                },
                child: const Text('ออกจากระบบ'),
              ),
            ],
          );
        },
      ),
    );
  }
}
