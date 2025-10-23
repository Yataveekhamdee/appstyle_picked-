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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนส่งรีวิว')),
      );
      return;
    }

    final name = _name.text.trim().isEmpty ? 'ไม่ระบุชื่อ' : _name.text.trim();
    final text = _text.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรอกข้อความรีวิวก่อนส่ง')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await _reviewsCol.add({
        'name': name,
        'text': text,
        'stars': _stars,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': user.uid,
      });

      _name.clear();
      _text.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งรีวิวเรียบร้อยแล้ว')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่งรีวิวไม่สำเร็จ: ${e.message ?? e.code}')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รีวิวสินค้า')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _reviewsCol.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? const [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text('เขียนรีวิวของคุณ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ (ไม่บังคับ)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _text,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ความคิดเห็น',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('ให้คะแนน:'),
                  for (int i = 1; i <= 5; i++)
                    IconButton(
                      icon: Icon(
                        i <= _stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => _stars = i),
                    ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ส่งรีวิว'),
                ),
              ),
              const Divider(height: 30),
              const Text('รีวิวจากผู้ใช้',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (docs.isEmpty)
                const Text('ยังไม่มีรีวิว',
                    style: TextStyle(color: Colors.grey)),
              ...docs.map((d) {
                final r = d.data();
                final name = (r['name'] ?? 'ไม่ระบุชื่อ').toString();
                final text = (r['text'] ?? '').toString();
                final stars = (r['stars'] ?? 0) is int ? r['stars'] as int : 0;

                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(text),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        stars,
                        (_) => const Icon(Icons.star,
                            color: Colors.amber, size: 16),
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
