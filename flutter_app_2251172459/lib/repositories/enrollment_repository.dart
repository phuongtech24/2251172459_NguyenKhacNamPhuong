import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enrollment_model.dart';
import '../models/course_model.dart';
import '../models/student_model.dart';

class EnrollmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'enrollments';

  // 1. Đăng ký Khóa học
  Future<void> enrollCourse(String studentId, String courseId) async {
    // Bước 1: Kiểm tra xem đã đăng ký chưa (tránh spam)
    final existingQuery = await _firestore
        .collection(collectionPath)
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .where('status', isNotEqualTo: 'dropped') // Status khác dropped nghĩa là đang học hoặc đã xong
        .get();

    if (existingQuery.docs.isNotEmpty) {
      throw Exception("Học viên đã đăng ký khóa học này rồi!");
    }

    // Bước 2: Dùng Transaction để vừa tạo Enrollment vừa tăng studentCount
    await _firestore.runTransaction((transaction) async {
      // Lấy reference đến Course để tăng biến đếm
      DocumentReference courseRef = _firestore.collection('courses').doc(courseId);
      
      // Tạo ID mới cho enrollment
      DocumentReference enrollmentRef = _firestore.collection(collectionPath).doc();

      // Tạo object Enrollment mới
      final newEnrollment = EnrollmentModel(
        enrollmentId: enrollmentRef.id,
        studentId: studentId,
        courseId: courseId,
        enrollmentDate: DateTime.now(),
        progress: 0,
        completedLessons: [],
        status: 'active',
        certificateIssued: false,
        lastAccessedAt: DateTime.now(),
      );

      // Thực hiện ghi vào DB
      transaction.set(enrollmentRef, newEnrollment.toMap());
      
      // Tăng số lượng học viên trong Course lên 1
      transaction.update(courseRef, {
        'studentCount': FieldValue.increment(1)
      });
    });
  }

  // 2. Cập nhật Tiến độ
  Future<void> updateProgress(String enrollmentId, String lessonId) async {
    DocumentReference enrollmentRef = _firestore.collection(collectionPath).doc(enrollmentId);

    await _firestore.runTransaction((transaction) async {
      // Đọc dữ liệu Enrollment hiện tại
      DocumentSnapshot enrollmentSnapshot = await transaction.get(enrollmentRef);
      if (!enrollmentSnapshot.exists) {
        throw Exception("Không tìm thấy đăng ký!");
      }

      EnrollmentModel enrollment = EnrollmentModel.fromMap(
        enrollmentSnapshot.data() as Map<String, dynamic>, 
        enrollmentSnapshot.id
      );

      // Nếu bài học này đã hoàn thành rồi thì không làm gì cả
      if (enrollment.completedLessons.contains(lessonId)) {
        return;
      }

      // Thêm lessonId vào danh sách
      List<String> updatedLessons = List.from(enrollment.completedLessons)..add(lessonId);
      
      // Lấy thông tin Course để biết tổng số bài học (lessonCount)
      DocumentReference courseRef = _firestore.collection('courses').doc(enrollment.courseId);
      DocumentSnapshot courseSnapshot = await transaction.get(courseRef);
      int totalLessons = courseSnapshot.get('lessonCount') ?? 1; // Mặc định 1 để tránh chia cho 0

      // Tính lại tiến độ
      int newProgress = ((updatedLessons.length / totalLessons) * 100).toInt();
      if (newProgress > 100) newProgress = 100;

      // Cập nhật trạng thái
      String newStatus = enrollment.status;
      bool newCertificateIssued = enrollment.certificateIssued;

      if (newProgress == 100) {
        newStatus = 'completed';
        newCertificateIssued = true;
      }

      // Ghi đè cập nhật
      transaction.update(enrollmentRef, {
        'completedLessons': updatedLessons,
        'progress': newProgress,
        'status': newStatus,
        'certificateIssued': newCertificateIssued,
        'lastAccessedAt': Timestamp.now(),
      });
    });
  }

  // 3. Lấy khóa học của Student (Kèm thông tin Course)
  Future<List<Map<String, dynamic>>> getEnrollmentsByStudent(String studentId) async {
    // Lấy danh sách enrollment
    final snapshot = await _firestore
        .collection(collectionPath)
        .where('studentId', isEqualTo: studentId)
        .get();

    List<Map<String, dynamic>> results = [];

    for (var doc in snapshot.docs) {
      final enrollment = EnrollmentModel.fromMap(doc.data(), doc.id);
      
      // Với mỗi enrollment, lấy thêm thông tin chi tiết khóa học
      final courseSnapshot = await _firestore.collection('courses').doc(enrollment.courseId).get();
      
      if (courseSnapshot.exists) {
        final course = CourseModel.fromMap(courseSnapshot.data()!, courseSnapshot.id);
        results.add({
          'enrollment': enrollment,
          'course': course, // Trả về cả 2 object
        });
      }
    }
    return results;
  }

  // 4. Lấy học viên của Course (Kèm thông tin Student)
  Future<List<Map<String, dynamic>>> getEnrollmentsByCourse(String courseId) async {
    final snapshot = await _firestore
        .collection(collectionPath)
        .where('courseId', isEqualTo: courseId)
        .get();

    List<Map<String, dynamic>> results = [];

    for (var doc in snapshot.docs) {
      final enrollment = EnrollmentModel.fromMap(doc.data(), doc.id);
      
      // Lấy thêm thông tin chi tiết học viên
      final studentSnapshot = await _firestore.collection('students').doc(enrollment.studentId).get();
      
      if (studentSnapshot.exists) {
        final student = StudentModel.fromMap(studentSnapshot.data()!, studentSnapshot.id);
        results.add({
          'enrollment': enrollment,
          'student': student,
        });
      }
    }
    return results;
  }

  // 5. Hủy đăng ký
  Future<void> dropEnrollment(String enrollmentId) async {
    await _firestore.runTransaction((transaction) async {
      DocumentReference enrollmentRef = _firestore.collection(collectionPath).doc(enrollmentId);
      DocumentSnapshot enrollmentSnapshot = await transaction.get(enrollmentRef);

      if (!enrollmentSnapshot.exists) return;

      String courseId = enrollmentSnapshot.get('courseId');
      String currentStatus = enrollmentSnapshot.get('status');

      // Chỉ giảm số lượng nếu khóa học chưa bị hủy trước đó
      if (currentStatus != 'dropped') {
        // Cập nhật trạng thái
        transaction.update(enrollmentRef, {'status': 'dropped'});

        // Giảm số lượng học viên
        DocumentReference courseRef = _firestore.collection('courses').doc(courseId);
        transaction.update(courseRef, {
          'studentCount': FieldValue.increment(-1)
        });
      }
    });
  }
}