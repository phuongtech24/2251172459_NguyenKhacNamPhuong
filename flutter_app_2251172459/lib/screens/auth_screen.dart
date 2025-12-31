import 'package:flutter/material.dart';
import 'package:flutter_app_2251172459/models/student_model.dart';
import 'package:flutter_app_2251172459/repositories/student_repository.dart';
import 'package:uuid/uuid.dart'; // Cần thêm: flutter pub add uuid
import '../../models/student_model.dart';
import '../../repositories/student_repository.dart';
import '../../utils/globals.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentRepo = StudentRepository();
  bool isLogin = true; // Chuyển đổi giữa Login và Register

  // Controllers
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _selectedDate = DateTime(2000);
  String _gender = 'male';

  // Hàm chọn ngày sinh
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Xử lý Submit
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isLogin) {
        // --- ĐĂNG NHẬP (Giả lập: Tìm theo email) ---
        // Trong thực tế nên dùng Firebase Auth
        final allStudents = await _studentRepo.getAllStudents();
        final student = allStudents.firstWhere(
          (s) => s.email == _emailController.text.trim(),
          orElse: () => throw Exception("Email không tồn tại!"),
        );
        currentStudentId = student.studentId;
      } else {
        // --- ĐĂNG KÝ ---
        final newId = const Uuid().v4();
        final newStudent = StudentModel(
          studentId: newId,
          email: _emailController.text.trim(),
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          dateOfBirth: _selectedDate,
          gender: _gender,
          createdAt: DateTime.now(),
          isActive: true,
        );
        await _studentRepo.addStudent(newStudent);
        currentStudentId = newId;
      }

      // Chuyển sang màn hình chính
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      // --- Error Handling (Phần 5) ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Đăng nhập" : "Đăng ký")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Cần nhập email" : null,
              ),
              if (!isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Họ tên"),
                  validator: (v) => v!.isEmpty ? "Cần nhập họ tên" : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Số điện thoại"),
                ),
                ListTile(
                  title: Text("Ngày sinh: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text("Nam")),
                    DropdownMenuItem(value: 'female', child: Text("Nữ")),
                    DropdownMenuItem(value: 'other', child: Text("Khác")),
                  ],
                  onChanged: (v) => setState(() => _gender = v!),
                  decoration: const InputDecoration(labelText: "Giới tính"),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isLogin ? "Đăng nhập" : "Đăng ký"),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Chưa có tài khoản? Đăng ký" : "Đã có tài khoản? Đăng nhập"),
              )
            ],
          ),
        ),
      ),
    );
  }
}