import 'package:flutter/material.dart';

class OrderPreparingPage extends StatelessWidget {
  const OrderPreparingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('เตรียมจัดส่งพัสดุ'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping, size: 84, color: cs.primary),
              const SizedBox(height: 12),
              const Text('ชำระเงินเสร็จสมบูรณ์',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('ร้านค้ากำลังเตรียมจัดส่งพัสดุของคุณ…'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                child: const Text('กลับหน้าหลัก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
