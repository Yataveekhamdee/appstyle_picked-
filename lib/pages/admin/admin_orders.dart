// lib/pages/admin/admin_orders.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('ออเดอร์ทั้งหมด')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('ยังไม่มีออเดอร์'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = Map<String, dynamic>.from(d.data() as Map);
              final id = d.id;

              final address = Map<String, dynamic>.from(data['address'] ?? {});
              final name = (address['name'] ?? '').toString();
              final phone = (address['phone'] ?? '').toString();
              final line1 = (address['line1'] ?? '').toString();
              final district = (address['district'] ?? '').toString();
              final province = (address['province'] ?? '').toString();
              final zip = (address['zip'] ?? '').toString();

              final total = (data['grandTotal'] ?? 0).toString();
              final method = (data['paymentMethod'] ?? '').toString();
              final status = (data['status'] ?? 'pending').toString();

              final payment = Map<String, dynamic>.from(data['payment'] ?? {});
              final slipUrl = (payment['slipUrl'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // หัวข้อ Order ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #$id',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('ลบออเดอร์'),
                                  content:
                                      Text('ยืนยันลบออเดอร์ #$id หรือไม่?'),
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
                              if (ok == true) {
                                await d.reference.delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('ลบออเดอร์ #$id แล้ว')),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      // ที่อยู่ลูกค้า
                      Text('$name • $phone',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('$line1'),
                      Text('$district $province $zip',
                          style: const TextStyle(color: Colors.black54)),

                      const SizedBox(height: 8),

                      // ยอดรวม + วิธีชำระ + สถานะ
                      Text('ยอดรวม ฿$total • $method',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('สถานะ: $status',
                          style: const TextStyle(color: Colors.black54)),

                      // รูปสลิป (ถ้ามี)
                      if (slipUrl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            slipUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                                height: 160,
                                child: Center(child: Text('โหลดรูปไม่ได้'))),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
