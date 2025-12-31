import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'students';

  // 1. Thêm Student
  Future<void> addStudent(StudentModel student) async {
    await _firestore
        .collection(collectionPath)
        .doc(student.studentId)
        .set(student.toMap());
  }

  // 2. Lấy Student theo ID
  Future<StudentModel?> getStudentById(String studentId) async {
    final doc = await _firestore.collection(collectionPath).doc(studentId).get();
    if (doc.exists) {
      return StudentModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // 3. Lấy tất cả Students
  Future<List<StudentModel>> getAllStudents() async {
    final snapshot = await _firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // 4. Cập nhật Student
  Future<void> updateStudent(StudentModel student) async {
    await _firestore
        .collection(collectionPath)
        .doc(student.studentId)
        .update(student.toMap());
  }

  // 5. Xóa Student (Có kiểm tra điều kiện)
  Future<void> deleteStudent(String studentId) async {
    // Kiểm tra xem học viên có đang đăng ký khóa học nào "active" không
    final activeEnrollments = await _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'active')
        .get();

    if (activeEnrollments.docs.isNotEmpty) {
      throw Exception("Không thể xóa: Học viên đang có khóa học chưa hoàn thành!");
    }

    await _firestore.collection(collectionPath).doc(studentId).delete();
  }
}