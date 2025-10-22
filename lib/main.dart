import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
// pages
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/auth/profile_page.dart';

import 'pages/products/product_list_page.dart';
import 'pages/products/product_reviews_page.dart';

// admin pages
import 'pages/admin/admin_dashboard.dart';
import 'pages/admin/admin_login_page.dart';
import 'pages/admin/admin_orders.dart';

// cart / address
import 'pages/cart/cart_page.dart';
import 'pages/cart/checkout_page.dart';
import 'pages/cart/order_preparing_page.dart';
import 'pages/cart/payment_detail_page.dart';

// providers
import 'providers/cart_store.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'pages/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => cartStore),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 255, 199, 218)), // ชมพู
        ),
        darkTheme: ThemeData(
          // จะไม่ถูกใช้ถ้าเรา fix เป็น light
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE91E63),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.light,

        // ถ้าอยากเริ่มที่หน้า Login ให้เปลี่ยนเป็น: home: const LoginPage(),
        initialRoute: '/login',

        routes: {
          '/login': (_) => const LoginPage(),
          '/signup': (_) => const SignupPage(),
          '/profile': (_) => const ProfilePage(),

          '/order':      (_) => const HomePage(),
          '/home'  : (_) => const HomePage(),
          '/products': (_) => const ProductListPage(),
          '/checkout': (_) => const CheckoutPage(),
          '/paymentDetail': (_) => const PaymentDetailPage(),
          '/cart': (_) => const CartPage(),
          '/orderPreparing': (_) => const OrderPreparingPage(),

          // admin
          '/AdminOrdersPage': (_) => const AdminOrdersPage(),
          '/admin': (_) => const AdminDashboard(),
          '/admin/login': (_) => const AdminLoginPage(),
         
        },
      ),
    );
  }
} 