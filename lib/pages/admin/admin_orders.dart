// lib/pages/admin/admin_orders.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (s, _) => s.data() ?? {},
          toFirestore: (m, _) => m,
        )
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('ออเดอร์ทั้งหมด')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q,
        builder: (_, s) {
          if (!s.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('ยังไม่มีออเดอร์'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final m = d.data();

              final addr =
                  (m['address'] as Map?)?.cast<String, dynamic>() ?? const {};
              final items = (m['items'] as List? ?? const [])
                  .map((e) => (e as Map).cast<String, dynamic>())
                  .toList();
              final slipUrl = (m['payment']?['slipUrl'] ?? '').toString();

              // "เสื้อยืด ×2, กางเกง ×1"
              final itemLine = items.isEmpty
                  ? '-'
                  : items
                      .map((x) => '${x['title']} x ${x['qty'] ?? 1}')
                      .join(', ');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // หัวเรื่อง + ปุ่มลบ
                        Row(children: [
                          Expanded(
                            child: Text('Order #${d.id}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('ลบออเดอร์?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('ยกเลิก')),
                                    FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('ลบ')),
                                  ],
                                ),
                              );
                              if (ok == true) await d.reference.delete();
                            },
                          ),
                        ]),

                        // ที่อยู่ / ยอดรวม / วิธีจ่าย / สถานะ
                        Text('${addr['name'] ?? ''} • ${addr['phone'] ?? ''}'),
                        Text(
                          '${addr['line1'] ?? ''}  ${addr['district'] ?? ''}  ${addr['province'] ?? ''} ${addr['zip'] ?? ''}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                            'ยอดรวม ฿${m['grandTotal'] ?? 0} • ${m['paymentMethod'] ?? ''}'),
                        Text('สถานะ: ${m['status'] ?? 'pending'}',
                            style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),

                        // รายการสินค้า (บรรทัดเดียว)
                        Text('สินค้า: $itemLine'),
                        const SizedBox(height: 8),

                        // สลิป (ถ้ามี)
                        if (slipUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              slipUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                height: 160,
                                child: Center(child: Text('โหลดรูปไม่ได้')),
                              ),
                            ),
                          ),
                      ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
