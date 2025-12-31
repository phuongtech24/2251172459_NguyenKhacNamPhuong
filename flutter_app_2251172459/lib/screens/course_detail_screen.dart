import 'package:flutter/material.dart';
import 'package:flutter_app_2251172459/models/course_model.dart';
import 'package:flutter_app_2251172459/repositories/enrollment_repository.dart';
import '../../utils/globals.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _enrollmentRepo = EnrollmentRepository();
  bool _isLoading = false;

  Future<void> _handleEnroll() async {
    setState(() => _isLoading = true);
    try {
      if (currentStudentId == null) throw Exception("Chưa đăng nhập!");
      
      await _enrollmentRepo.enrollCourse(currentStudentId!, widget.course.courseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công!")),
        );
        Navigator.pop(context); // Quay lại
      }
    } catch (e) {
      // --- Error Handling (Phần 5) ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200, width: double.infinity, color: Colors.grey[300],
              child: const Icon(Icons.video_library, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(widget.course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Giảng viên: ${widget.course.instructor}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Chip(label: Text(widget.course.level)),
            const SizedBox(height: 16),
            Text(widget.course.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleEnroll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16)
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ĐĂNG KÝ NGAY", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}