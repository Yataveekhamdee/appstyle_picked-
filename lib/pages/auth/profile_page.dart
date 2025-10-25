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
  void dispose() {
    _name.dispose(); // เคลียร์ controller ตอนปิดหน้านี้ (กันเปลืองหน่วยความจำ)
    super.dispose();
  }

  // ฟังก์ชันสร้างตัวอักษรตัวแรกในวงกลม Avatar
 
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
    // currentUser = ข้อมูลคนที่ล็อกอินอยู่ตอนนี้ (จาก Firebase Auth)

  
    if (user == null) {
      Future.microtask(() =>
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false));
      
      return const SizedBox.shrink();
    }

    // อ้างอิง document ของผู้ใช้คนนี้ใน Firestore
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์ของฉัน')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(), // ฟังการเปลี่ยนแปลงแบบ real-time จาก Firestore
        builder: (context, snap) {
          
          if (snap.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snap.error}'));
          }

          
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ดึง data จาก Firestore
          // ถ้า doc ยังไม่เคยมี (ผู้ใช้ใหม่) -> ใช้ {} ว่างแทน
          final data = snap.data?.data() ?? {};

          
          // ทำแบบนี้เพื่อไม่ให้เคอร์เซอร์เด้งทุกครั้งที่ StreamBuilder รีเฟรช
          if (_name.text.isEmpty && (data['name'] ?? '').toString().isNotEmpty) {
            _name.text = data['name'];
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
             
              CircleAvatar(
                radius: 40,
                child: Text(
                  _avatarLetter(data, user.email), // ตัวอักษรหัวชื่อ
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

             
              Text('อีเมล', style: Theme.of(context).textTheme.labelMedium),
              Text(
                user.email ?? '-', // ถ้า user.email ไม่มีค่า ให้แสดง '-'
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

            
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'ชื่อที่แสดง'),
              ),
              const SizedBox(height: 12),

             
              
              // _saving = true ระหว่างทำงาน -> ปิดปุ่มไม่ให้กดซ้ำ และโชว์วงกลมหมุน
              FilledButton(
                onPressed: _saving ? null : () async {
                  setState(() => _saving = true);
                  try {
                    await doc.set(
                      {'name': _name.text.trim()},
                      SetOptions(merge: true),
                      // merge:true = อัปเดตเฉพาะฟิลด์ name ไม่ลบฟิลด์อื่น
                    );

                    await user.updateDisplayName(_name.text.trim());
                    // sync ชื่อใหม่กลับไปที่ Firebase Auth ด้วย
               

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
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('บันทึก'),
              ),
              const SizedBox(height: 24),

             
              // 1. FirebaseAuth.instance.signOut() = ออกจากระบบ
              // 2. เด้งกลับไปหน้า /login และเคลียร์เส้นทางเก่า (back กลับไม่ได้)
              OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
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

