import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_2251172459/firebase_options.dart';

// Import màn hình Auth để làm màn hình chính
// Đảm bảo bạn đã tạo file này ở bước trước: lib/screens/auth_screen.dart
import 'screens/auth_screen.dart';

void main() async {
  // BẮT BUỘC: Đảm bảo Flutter Engine khởi động trước khi gọi Firebase
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
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG ở góc phải
      title: 'LMS - 2251172459', // Đặt tên App theo MSV
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Màn hình đầu tiên khi mở App là màn hình Đăng nhập/Đăng ký
      home: const AuthScreen(),
    );
  }
}