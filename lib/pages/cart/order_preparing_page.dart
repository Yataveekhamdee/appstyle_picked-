import 'package:flutter/material.dart';

class OrderPreparingPage extends StatelessWidget {
  const OrderPreparingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final total = (args['grandTotal'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('เตรียมจัดส่งพัสดุ'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping, size: 80, color: Colors.green),
            const SizedBox(height: 12),
            const Text('ชำระเงินเสร็จสมบูรณ์'),
            const SizedBox(height: 4),
            Text('ยอดชำระ ฿${total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            const Text('ร้านค้ากำลังเตรียมจัดส่งพัสดุของคุณ…'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
              child: const Text('กลับหน้าหลัก'),
            ),
          ],
        ),
      ),
    );
  }
}
