import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_2251172459/models/course_model.dart';
import 'package:flutter_app_2251172459/models/enrollment_model.dart';
import 'package:flutter_app_2251172459/repositories/enrollment_repository.dart';
import '../../utils/globals.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Khóa học của tôi"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Đang học"),
              Tab(text: "Chứng chỉ"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCourseList(context, showCertificates: false),
            _buildCourseList(context, showCertificates: true),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, {required bool showCertificates}) {
    // --- Real-time Updates (Phần 5) ---
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('enrollments')
          .where('studentId', isEqualTo: currentStudentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var enrollments = snapshot.data!.docs
            .map((d) => EnrollmentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList();

        // Lọc theo Tab
        if (showCertificates) {
          enrollments = enrollments.where((e) => e.status == 'completed').toList();
        } else {
          enrollments = enrollments.where((e) => e.status != 'completed').toList(); // Active hoặc dropped
        }

        if (enrollments.isEmpty) {
          return const Center(child: Text("Không có dữ liệu"));
        }

        return ListView.builder(
          itemCount: enrollments.length,
          itemBuilder: (context, index) {
            final enrollment = enrollments[index];
            
            // Cần lấy thông tin Course để hiển thị tên
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('courses').doc(enrollment.courseId).get(),
              builder: (context, courseSnap) {
                if (!courseSnap.hasData) return const SizedBox.shrink();
                
                final course = CourseModel.fromMap(courseSnap.data!.data() as Map<String, dynamic>, courseSnap.data!.id);

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        LinearProgressIndicator(value: enrollment.progress / 100),
                        const SizedBox(height: 5),
                        Text("Tiến độ: ${enrollment.progress}%"),
                        if (showCertificates)
                          Text("Cấp ngày: ${enrollment.lastAccessedAt?.toIso8601String().split('T')[0]}", 
                              style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                    trailing: _buildStatusBadge(enrollment.status),
                    onTap: () {
                      if (!showCertificates) {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_) => LearningScreen(enrollment: enrollment, course: course)
                          )
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.blue;
    if (status == 'completed') color = Colors.green;
    if (status == 'dropped') color = Colors.red;
    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
    );
  }
}

// --- Màn hình Học tập (Learning Screen) ---
class LearningScreen extends StatefulWidget {
  final EnrollmentModel enrollment;
  final CourseModel course;
  const LearningScreen({super.key, required this.enrollment, required this.course});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final _enrollmentRepo = EnrollmentRepository();

  @override
  Widget build(BuildContext context) {
    // Giả lập danh sách bài học dựa trên lessonCount của Course
    final List<String> lessons = List.generate(widget.course.lessonCount, (index) => "Lesson ${index + 1}");

    return Scaffold(
      appBar: AppBar(title: Text("Đang học: ${widget.course.title}")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: widget.enrollment.progress / 100, 
              minHeight: 10,
              color: Colors.green,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lessonId = "lesson_${index + 1}"; // Giả lập ID
                final isCompleted = widget.enrollment.completedLessons.contains(lessonId);

                return CheckboxListTile(
                  title: Text(lessons[index]),
                  value: isCompleted,
                  onChanged: (val) async {
                    if (val == true && !isCompleted) {
                      try {
                        await _enrollmentRepo.updateProgress(widget.enrollment.enrollmentId, lessonId);
                        // Khi transaction xong, Stream ở màn hình trước sẽ tự update, 
                        // nhưng màn hình này cần setState hoặc StreamBuilder để thấy ngay.
                        // Để đơn giản ta pop ra cho user thấy list update hoặc hiển thị thông báo.
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã hoàn thành bài học!")));
                        Navigator.pop(context); // Quay ra để thấy update (hoặc convert màn hình này sang StreamBuilder)
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}