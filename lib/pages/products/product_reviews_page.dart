import 'package:flutter/material.dart';              
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';    

class ProductReviewsPage extends StatefulWidget {
  final String productId; 
  const ProductReviewsPage({super.key, required this.productId});

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  final _name = TextEditingController(); 
  final _text = TextEditingController(); 
  int _stars = 5;                        
  bool _sending = false;                 

  CollectionReference<Map<String, dynamic>> get _reviewsCol =>
      FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews');


  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser; // คนที่ล็อกอินตอนนี้
    if (user == null) {

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนส่งรีวิว')),
      );
      return;
    }

    // ถ้าไม่ได้กรอกชื่อ ให้ใช้คำว่า "ไม่ระบุชื่อ"
    final name = _name.text.trim().isEmpty ? 'ไม่ระบุชื่อ' : _name.text.trim();

    // ข้อความรีวิวจริง
    final text = _text.text.trim();

    // กันเคส: ไม่พิมพ์อะไรเลยแล้วกดส่ง
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรอกข้อความรีวิวก่อนส่ง')),
      );
      return;
    }

    setState(() => _sending = true); 

    try {
      // เพิ่มรีวิวใหม่ 1 อันลงใน Firestore
      await _reviewsCol.add({
        'name': name,                           
        'text': text,                              
        'stars': _stars,                           
        'createdAt': FieldValue.serverTimestamp(), 
        'uid': user.uid,                         
      });

      // เคลียร์ฟอร์มหลังส่งเสร็จ
      _name.clear();
      _text.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งรีวิวเรียบร้อยแล้ว')),
      );
    } on FirebaseException catch (e) {
      // ถ้าส่งไม่สำเร็จ (ปัญหาเน็ต / สิทธิ์ Firestore)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่งรีวิวไม่สำเร็จ: ${e.message ?? e.code}')),
      );
    } finally {
      // กลับมาปลดล็อกปุ่มส่ง
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    // เคลียร์ controller ตอนปิดหน้า ป้องกัน memory รั่ว
    _name.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // โครงหน้าจอ
      appBar: AppBar(title: const Text('รีวิวสินค้า')), // หัวจอ

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // ดึงรีวิวทั้งหมดของสินค้านี้แบบ realtime (อัปเดตสด)
        stream: _reviewsCol
            .orderBy('createdAt', descending: true) // เรียงใหม่ไปเก่า
            .snapshots(),
        builder: (context, snap) {
          // ระหว่างรอโหลดรีวิวครั้งแรก -> หมุนโหลด
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // เอารีวิวทั้งหมดออกมาจาก snapshot ถ้าไม่มี ก็เป็น []
          final docs = snap.data?.docs ?? const [];

          // สร้างทั้งหน้าเป็น ListView เลื่อนรวมได้
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              
              const Text(
                'เขียนรีวิวของคุณ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // ช่องกรอกชื่อเล่น (ไม่บังคับ)
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ (ไม่บังคับ)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 8),

              // ช่องใส่ข้อความรีวิว
              TextField(
                controller: _text,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ความคิดเห็น',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 8),

              // แถวเลือกดาว 1-5
              Row(
                children: [
                  const Text('ให้คะแนน:'),
                  for (int i = 1; i <= 5; i++)
                    IconButton(
                      icon: Icon(
                        i <= _stars
                            ? Icons.star       
                            : Icons.star_border, 
                        color: Colors.amber,
                      ),
                      onPressed: () =>
                          setState(() => _stars = i), 
                    ),
                ],
              ),

              // ปุ่ม "ส่งรีวิว"
              SizedBox(
                width: double.infinity, 
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  // ถ้า _sending = true ปุ่มจะกดไม่ได้

                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ) // โชว์วงกลมหมุนตอนกำลังส่ง
                      : const Text('ส่งรีวิว'),
                ),
              ),

              const Divider(height: 30),

            
              const Text(
                'รีวิวจากผู้ใช้',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (docs.isEmpty)

                const Text(
                  'ยังไม่มีรีวิว',
                  style: TextStyle(color: Colors.grey),
                ),

              // สร้างการ์ดรีวิวจากข้อมูล Firestore ทีละอัน
              ...docs.map((d) {
                final r = d.data(); // map ของรีวิว 1 อัน
                final name =
                    (r['name'] ?? 'ไม่ระบุชื่อ').toString(); 
                final text =
                    (r['text'] ?? '').toString();             
                final stars =
                    (r['stars'] ?? 0) is int ? r['stars'] as int : 0; 

                return Card(
                  child: ListTile(
                    title: Text(name), // แสดงชื่อคนรีวิว
                    subtitle: Text(text), // แสดงข้อความรีวิว
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        stars,
                        (_) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ), // วาดดาวตามคะแนน
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

