# LMS Mobile App - Bài Tập Lớn Flutter

**Họ tên:** Nguyễn Khắc Nam Phương
**Mã Sinh Viên:** 2251172459  
**Lớp:** 64KTPM5

---

## 1. Giới thiệu
Ứng dụng LMS (Learning Management System) là nền tảng học tập trực tuyến trên thiết bị di động, được xây dựng bằng **Flutter** và **Firebase**. Ứng dụng cho phép sinh viên xem danh sách khóa học, tìm kiếm, lọc theo danh mục, xem chi tiết và theo dõi tiến độ học tập.

## 2. Các chức năng (Checklist)
Dự án đã hoàn thành đầy đủ các yêu cầu của Checklist nộp bài:

- [x] **Project hoàn chỉnh:** Có thể chạy được trên Android/iOS simulator.
- [x] **Firebase Integration:** Kết nối thành công Firestore Database.
- [x] **Dữ liệu mẫu:** - Có 5 students (Collection: `students`).
    - Có 12 courses đầy đủ category/level (Collection: `courses`).
    - Có 10 enrollments với các trạng thái khác nhau (Collection: `enrollments`).
- [x] **Chức năng CRUD:** Xem danh sách, Chi tiết, Tìm kiếm, Lọc.
- [x] **UI/UX:** Giao diện hiển thị dữ liệu động từ Firestore, có loading state.
- [x] **Real-time Updates:** Sử dụng `StreamBuilder` để cập nhật dữ liệu tức thì.
- [x] **Error Handling:** Xử lý các trường hợp loading, lỗi mạng, dữ liệu rỗng.
- [x] **Code Structure:** Tổ chức code rõ ràng (Models, Screens, Utils).

## 3. Cấu trúc CSDL (Firestore)

### Collection: `students`
Lưu trữ thông tin sinh viên.
- `studentId` (String): Mã định danh (Primary Key).
- `fullName` (String): Họ tên.
- `email` (String): Email.
- `phoneNumber` (String): Số điện thoại.
- `gender` (String): Giới tính.
- `dateOfBirth` (Timestamp): Ngày sinh.
- `isActive` (Boolean): Trạng thái hoạt động.

### Collection: `courses`
Lưu trữ thông tin khóa học.
- `id` (String): Mã khóa học.
- `title` (String): Tên khóa học.
- `category` (String): Danh mục (Programming, Design, Business).
- `level` (String): Cấp độ (Beginner, Intermediate, Advanced).
- `price` (Number): Giá tiền.
- `rating` (Number): Đánh giá sao.
- `instructor` (String): Giảng viên.

### Collection: `enrollments`
Lưu trữ thông tin đăng ký học.
- `id` (String): Mã đăng ký.
- `studentId` (String): FK tới students.
- `courseId` (String): FK tới courses.
- `status` (String): Trạng thái (completed, ongoing, cancelled).
- `progress` (Number): Tiến độ (%).

## 4. Hướng dẫn cài đặt
1. Clone project về máy.
2. Chạy lệnh `flutter pub get` để tải thư viện.
3. Đảm bảo file `google-services.json` đã nằm trong thư mục `android/app`.
4. Chạy ứng dụng: `flutter run`.