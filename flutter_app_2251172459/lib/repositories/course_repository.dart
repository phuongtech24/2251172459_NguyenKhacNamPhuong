import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CourseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'courses';

  // 1. Thêm Course
  Future<void> addCourse(CourseModel course) async {
    await _firestore
        .collection(collectionPath)
        .doc(course.courseId)
        .set(course.toMap());
  }

  // 2. Lấy Course theo ID
  Future<CourseModel?> getCourseById(String courseId) async {
    final doc = await _firestore.collection(collectionPath).doc(courseId).get();
    if (doc.exists) {
      return CourseModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // 3. Lấy tất cả Courses
  Future<List<CourseModel>> getAllCourses() async {
    final snapshot = await _firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // 4. Tìm kiếm Courses (Tìm trong title, description, instructor)
  // Lưu ý: Firestore không hỗ trợ tìm kiếm "contains" native.
  // Ta sẽ lấy data về và lọc phía Client cho bài toán này.
  Future<List<CourseModel>> searchCourses(String query) async {
    final allCourses = await getAllCourses();
    final lowerQuery = query.toLowerCase();

    return allCourses.where((course) {
      return course.title.toLowerCase().contains(lowerQuery) ||
          course.description.toLowerCase().contains(lowerQuery) ||
          course.instructor.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // 5. Lọc Courses (Category, Level, Price Range)
  Future<List<CourseModel>> filterCourses({
    String? category,
    String? level,
    double? minPrice,
    double? maxPrice,
  }) async {
    Query query = _firestore.collection(collectionPath);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (level != null && level.isNotEmpty) {
      query = query.where('level', isEqualTo: level);
    }

    // Lưu ý: Firestore yêu cầu tạo Composite Index nếu query nhiều trường.
    // Nếu chạy bị lỗi, hãy xem Log Console để bấm vào link tạo Index.
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}