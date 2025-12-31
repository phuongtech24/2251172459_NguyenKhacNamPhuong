import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_2251172459/models/course_model.dart';
import '../../utils/globals.dart';
import 'course_detail_screen.dart';
import 'my_courses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  String? _filterCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- YÊU CẦU BẮT BUỘC: AppBar chứa MSV ---
      appBar: AppBar(
        title: const Text("LMS - 2251172459"),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
            ),
          )
        ],
      ),
      
      // --- PHẦN MỚI THÊM: NÚT ĐỂ IMPORT DATA ---
      // (Xóa đoạn này trước khi nộp bài nếu thầy cô cấm để nút lạ)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Hiển thị thông báo đang chạy
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đang import dữ liệu mẫu... Vui lòng đợi!"))
          );
          
          await seedData(); // Gọi hàm import
          
          // Thông báo xong
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Đã Import xong! Hãy kéo để làm mới."))
            );
          }
        },
        label: const Text("Import Data"),
        icon: const Icon(Icons.cloud_upload),
        backgroundColor: Colors.redAccent, // Màu đỏ để dễ thấy đây là nút test
      ),
      // ------------------------------------------

      body: Column(
        children: [
          // --- Tìm kiếm và Lọc ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Tìm kiếm khóa học...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filterCategory,
                  hint: const Text("Loại"),
                  items: ["Programming", "Design", "Business"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _filterCategory = val),
                ),
                if (_filterCategory != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _filterCategory = null),
                  )
              ],
            ),
          ),

          // --- Danh sách khóa học (Real-time Updates - Phần 5) ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Lỗi tải dữ liệu"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Xử lý lọc dữ liệu phía Client (cho đơn giản)
                var docs = snapshot.data!.docs;
                var courses = docs
                    .map((d) => CourseModel.fromMap(
                        d.data() as Map<String, dynamic>, d.id))
                    .toList();

                // Áp dụng bộ lọc
                var filteredCourses = courses.where((c) {
                  final matchesSearch = c.title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                  final matchesCategory =
                      _filterCategory == null || c.category == _filterCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                return ListView.builder(
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.image), // Placeholder cho ImageUrl
                        ),
                        title: Text(course.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("GV: ${course.instructor} - \$${course.price}"),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: Colors.amber),
                                Text(
                                    " ${course.rating} (${course.studentCount} HV)"),
                              ],
                            )
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseDetailScreen(course: course),
                            ),
                          );
                        },
                      ),
                    );
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

// ============================================================================
// HÀM SEED DATA (Copy ở đây để không phải tạo file mới)
// ============================================================================

// ... Các phần import và class HomeScreen giữ nguyên ...

// ============================================================================
// HÀM SEED DATA (ĐÃ SỬA: users -> students)
// ============================================================================

Future<void> seedData() async {
  final firestore = FirebaseFirestore.instance;
  print("🚀 Bắt đầu import dữ liệu...");

  // 1. DATA STUDENTS
  final List<Map<String, dynamic>> sampleStudents = [ // Đổi tên biến cho chuẩn
    {
      "studentId": "user_001_id",
      "fullName": "Nguyễn Văn An",
      "email": "an.nguyen@gmail.com",
      "phoneNumber": "0987654321",
      "gender": "male",
      "dateOfBirth": "2000-01-15T00:00:00Z",
      "createdAt": "2023-12-01T08:00:00Z",
      "avatarUrl": "https://i.pravatar.cc/150?u=user_001",
      "isActive": true
    },
    {
      "studentId": "user_002_id",
      "fullName": "Trần Thị Bích",
      "email": "bich.tran@gmail.com",
      "phoneNumber": "0912345678",
      "gender": "female",
      "dateOfBirth": "2001-05-20T00:00:00Z",
      "createdAt": "2023-12-05T09:30:00Z",
      "avatarUrl": "https://i.pravatar.cc/150?u=user_002",
      "isActive": true
    },
    {
      "studentId": "user_003_id",
      "fullName": "Lê Hoàng Nam",
      "email": "nam.le@gmail.com",
      "phoneNumber": "0977889900",
      "gender": "male",
      "dateOfBirth": "1999-11-10T00:00:00Z",
      "createdAt": "2023-12-10T14:15:00Z",
      "avatarUrl": "https://i.pravatar.cc/150?u=user_003",
      "isActive": true
    },
    {
      "studentId": "user_004_id",
      "fullName": "Phạm Minh Tuấn",
      "email": "tuan.pham@gmail.com",
      "phoneNumber": "0966554433",
      "gender": "male",
      "dateOfBirth": "2002-03-25T00:00:00Z",
      "createdAt": "2023-12-15T10:00:00Z",
      "avatarUrl": "https://i.pravatar.cc/150?u=user_004",
      "isActive": true
    },
    {
      "studentId": "user_005_id",
      "fullName": "Đỗ Thu Hà",
      "email": "ha.do@gmail.com",
      "phoneNumber": "0933221100",
      "gender": "female",
      "dateOfBirth": "2000-08-30T00:00:00Z",
      "createdAt": "2023-12-20T16:45:00Z",
      "avatarUrl": "https://i.pravatar.cc/150?u=user_005",
      "isActive": true
    }
  ];

  // 2. DATA COURSES (Giữ nguyên)
  final List<Map<String, dynamic>> sampleCourses = [
    {
      "id": "course_001",
      "title": "Lập trình Flutter cơ bản",
      "description": "Khóa học xây dựng ứng dụng mobile từ con số 0 với Flutter.",
      "category": "Programming",
      "level": "Beginner",
      "price": 500000,
      "rating": 5,
      "instructor": "Thầy Phương",
      "lessonCount": 15,
      "studentCount": 120,
      "isPublished": true,
      "createdAt": "2023-10-01T08:00:00Z",
      "imageUrl": "https://img.youtube.com/vi/x0uinJvhNxI/maxresdefault.jpg"
    },
    // ... (Giữ nguyên các course còn lại để code ngắn gọn, không cần copy lại phần này nếu bạn đã có) ...
     {
      "id": "course_002",
      "title": "ReactJS Nâng cao",
      "description": "Thành thạo React Hooks và Redux trong 4 tuần.",
      "category": "Programming",
      "level": "Advanced",
      "price": 800000,
      "rating": 4.5,
      "instructor": "Cô Lan",
      "lessonCount": 20,
      "studentCount": 85,
      "isPublished": true,
      "createdAt": "2023-10-05T09:00:00Z",
      "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/1200px-React-icon.svg.png"
    },
    {
      "id": "course_003",
      "title": "Data Science với Python",
      "description": "Phân tích dữ liệu lớn và trực quan hóa với Pandas/Matplotlib.",
      "category": "Data Science",
      "level": "Intermediate",
      "price": 600000,
      "rating": 4.8,
      "instructor": "Thầy Hùng",
      "lessonCount": 18,
      "studentCount": 200,
      "isPublished": true,
      "createdAt": "2023-10-10T10:00:00Z",
      "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/1200px-Python-logo-notext.svg.png"
    },
    {
      "id": "course_004",
      "title": "Thiết kế UI/UX với Figma",
      "description": "Học tư duy thiết kế và sử dụng Figma chuyên nghiệp.",
      "category": "Design",
      "level": "Beginner",
      "price": 450000,
      "rating": 4.9,
      "instructor": "Cô Mai",
      "lessonCount": 12,
      "studentCount": 150,
      "isPublished": true,
      "createdAt": "2023-10-15T11:00:00Z",
      "imageUrl": "https://s3-alpha.figma.com/hub/file/1166690750/85e7273c-8481-4b69-a684-17953282b673-cover.png"
    },
    {
      "id": "course_005",
      "title": "Digital Marketing 101",
      "description": "Chiến lược Marketing trên mạng xã hội Facebook và TikTok.",
      "category": "Business",
      "level": "Beginner",
      "price": 300000,
      "rating": 4.2,
      "instructor": "Thầy Tuấn",
      "lessonCount": 10,
      "studentCount": 300,
      "isPublished": true,
      "createdAt": "2023-10-20T14:00:00Z",
      "imageUrl": "https://cdn.searchenginejournal.com/wp-content/uploads/2021/08/digital-marketing-fundamentals-611a25d2c2c62-sej.jpg"
    },
    {
      "id": "course_006",
      "title": "Machine Learning Cơ bản",
      "description": "Nhập môn trí tuệ nhân tạo và học máy.",
      "category": "Data Science",
      "level": "Beginner",
      "price": 700000,
      "rating": 4.6,
      "instructor": "Thầy Hùng",
      "lessonCount": 25,
      "studentCount": 90,
      "isPublished": true,
      "createdAt": "2023-10-25T15:00:00Z",
      "imageUrl": "https://miro.medium.com/v2/resize:fit:1400/1*c_fiB-YgbnMl6nntYGBMHQ.jpeg"
    },
    {
      "id": "course_007",
      "title": "NodeJS & MongoDB Backend",
      "description": "Xây dựng RESTful API mạnh mẽ cho ứng dụng web.",
      "category": "Programming",
      "level": "Intermediate",
      "price": 550000,
      "rating": 4.7,
      "instructor": "Thầy Phương",
      "lessonCount": 22,
      "studentCount": 110,
      "isPublished": true,
      "createdAt": "2023-11-01T08:30:00Z",
      "imageUrl": "https://miro.medium.com/v2/resize:fit:1200/1*y6C4nSvy2Woe0m7bWEn4BA.png"
    },
    {
      "id": "course_008",
      "title": "Adobe Photoshop Master",
      "description": "Chỉnh sửa ảnh và thiết kế banner quảng cáo.",
      "category": "Design",
      "level": "Intermediate",
      "price": 400000,
      "rating": 4.8,
      "instructor": "Cô Mai",
      "lessonCount": 15,
      "studentCount": 130,
      "isPublished": true,
      "createdAt": "2023-11-05T09:30:00Z",
      "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Adobe_Photoshop_CC_icon.svg/1200px-Adobe_Photoshop_CC_icon.svg.png"
    },
    {
      "id": "course_009",
      "title": "Quản trị kinh doanh",
      "description": "Kỹ năng quản lý đội nhóm và vận hành doanh nghiệp nhỏ.",
      "category": "Business",
      "level": "Advanced",
      "price": 900000,
      "rating": 4.5,
      "instructor": "Thầy Tuấn",
      "lessonCount": 30,
      "studentCount": 50,
      "isPublished": true,
      "createdAt": "2023-11-10T10:30:00Z",
      "imageUrl": "https://hbr.org/resources/images/article_assets/2019/11/Nov19_25_943063548.jpg"
    },
    {
      "id": "course_010",
      "title": "Deep Learning & AI",
      "description": "Mạng nơ-ron nhân tạo và Computer Vision với TensorFlow.",
      "category": "Data Science",
      "level": "Advanced",
      "price": 1000000,
      "rating": 5,
      "instructor": "Thầy Hùng",
      "lessonCount": 40,
      "studentCount": 40,
      "isPublished": true,
      "createdAt": "2023-11-15T13:00:00Z",
      "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Tensorflow_logo.svg/115px-Tensorflow_logo.svg.png"
    },
    {
      "id": "course_011",
      "title": "Java Spring Boot",
      "description": "Lập trình backend doanh nghiệp với Java.",
      "category": "Programming",
      "level": "Advanced",
      "price": 750000,
      "rating": 4.4,
      "instructor": "Cô Lan",
      "lessonCount": 28,
      "studentCount": 70,
      "isPublished": true,
      "createdAt": "2023-11-20T14:00:00Z",
      "imageUrl": "https://miro.medium.com/v2/resize:fit:1400/1*mE7FvWcM3d2A9n9d5zVw6Q.png"
    },
    {
      "id": "course_012",
      "title": "Lý thuyết màu sắc",
      "description": "Ứng dụng màu sắc trong thiết kế đồ họa và nội thất.",
      "category": "Design",
      "level": "Beginner",
      "price": 250000,
      "rating": 4.3,
      "instructor": "Cô Mai",
      "lessonCount": 8,
      "studentCount": 180,
      "isPublished": true,
      "createdAt": "2023-11-25T15:30:00Z",
      "imageUrl": "https://99designs-blog.imgix.net/blog/wp-content/uploads/2018/09/WHAT-IS-GRAPHIC-DESIGN.jpg?auto=format&q=60&fit=max&w=930"
    }
  ];

  // 3. DATA ENROLLMENTS (Giữ nguyên)
  final List<Map<String, dynamic>> sampleEnrollments = [
    {
      "id": "enroll_001",
      "studentId": "user_001_id",
      "courseId": "course_001",
      "progress": 100,
      "status": "completed",
      "enrolledDate": "2023-12-02T08:00:00Z"
    },
    {
      "id": "enroll_002",
      "studentId": "user_001_id",
      "courseId": "course_004",
      "progress": 50,
      "status": "ongoing",
      "enrolledDate": "2023-12-05T09:00:00Z"
    },
    {
      "id": "enroll_003",
      "studentId": "user_002_id",
      "courseId": "course_003",
      "progress": 10,
      "status": "ongoing",
      "enrolledDate": "2023-12-06T10:00:00Z"
    },
    {
      "id": "enroll_004",
      "studentId": "user_002_id",
      "courseId": "course_005",
      "progress": 100,
      "status": "completed",
      "enrolledDate": "2023-12-01T11:00:00Z"
    },
    {
      "id": "enroll_005",
      "studentId": "user_003_id",
      "courseId": "course_001",
      "progress": 0,
      "status": "ongoing",
      "enrolledDate": "2023-12-11T14:00:00Z"
    },
    {
      "id": "enroll_006",
      "studentId": "user_003_id",
      "courseId": "course_009",
      "progress": 5,
      "status": "cancelled",
      "enrolledDate": "2023-12-12T15:00:00Z"
    },
    {
      "id": "enroll_007",
      "studentId": "user_004_id",
      "courseId": "course_002",
      "progress": 80,
      "status": "ongoing",
      "enrolledDate": "2023-12-16T16:00:00Z"
    },
    {
      "id": "enroll_008",
      "studentId": "user_004_id",
      "courseId": "course_010",
      "progress": 100,
      "status": "completed",
      "enrolledDate": "2023-12-01T08:30:00Z"
    },
    {
      "id": "enroll_009",
      "studentId": "user_005_id",
      "courseId": "course_006",
      "progress": 65,
      "status": "ongoing",
      "enrolledDate": "2023-12-21T09:30:00Z"
    },
    {
      "id": "enroll_010",
      "studentId": "user_005_id",
      "courseId": "course_012",
      "progress": 20,
      "status": "ongoing",
      "enrolledDate": "2023-12-22T10:30:00Z"
    }
  ];

  // THỰC THI IMPORT
  // 1. STUDENTS
  for (var student in sampleStudents) {
    student['createdAt'] = DateTime.parse(student['createdAt']);
    student['dateOfBirth'] = DateTime.parse(student['dateOfBirth']);
    // SỬA: collection 'students' thay vì 'users'
    await firestore.collection('students').doc(student['studentId']).set(student);
    print("✅ Đã thêm Student: ${student['fullName']}");
  }

  // 2. COURSES
  for (var course in sampleCourses) {
    course['createdAt'] = DateTime.parse(course['createdAt']);
    await firestore.collection('courses').doc(course['id']).set(course);
    print("✅ Đã thêm Course: ${course['title']}");
  }

  // 3. ENROLLMENTS
  for (var enroll in sampleEnrollments) {
    enroll['enrolledDate'] = DateTime.parse(enroll['enrolledDate']);
    await firestore.collection('enrollments').doc(enroll['id']).set(enroll);
    print("✅ Đã thêm Enrollment: ${enroll['id']}");
  }

  print("🎉 HOÀN TẤT IMPORT DỮ LIỆU!");
}