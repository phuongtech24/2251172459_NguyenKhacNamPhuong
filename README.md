# 🎓 LMS Mobile App - Ứng Dụng Quản Lý Khóa Học

> **Bài tập lớn môn Lập trình thiết bị di động (Flutter)**

---

## 👨‍💻 Thông tin sinh viên

| Mục | Thông tin |
| :--- | :--- |
| **Họ và tên** | **Nguyễn Khắc Nam Phương** |
| **Mã sinh viên** | **2251172459** |
| **Lớp** | **64KTPM5** |

---

## 1. 📖 Giới thiệu
**LMS App** là ứng dụng di động được xây dựng nhằm mục đích giúp sinh viên dễ dàng tra cứu, tìm kiếm và quản lý các khóa học trực tuyến. 

Ứng dụng áp dụng kiến trúc chuẩn, kết hợp sức mạnh của **Flutter** (Frontend) và **Firebase Firestore** (Backend) để đảm bảo trải nghiệm mượt mà và cập nhật dữ liệu theo thời gian thực (Real-time).

---

## 2. 🛠 Công nghệ & Thư viện sử dụng
Dự án sử dụng các công nghệ và gói thư viện (packages) sau:

* **Ngôn ngữ:** Dart (SDK >= 3.0)
* **Framework:** Flutter
* **Backend:** Google Firebase (Firestore Database)
* **Các thư viện chính:**
    * `firebase_core`: Khởi tạo kết nối Firebase.
    * `cloud_firestore`: Tương tác với cơ sở dữ liệu NoSQL.
    * `cupertino_icons`: Bộ icon chuẩn iOS.
    * `material_design`: Giao diện chuẩn Android.

---

## 3. 📸 Demo Ứng dụng (Screenshots)

*(Lưu ý: Giảng viên có thể xem hình ảnh minh họa các màn hình chính dưới đây)*

| Màn hình chính | Chi tiết khóa học | Khóa học của tôi |
| :---: | :---: | :---: |
| <img src="screenshots/home.png" width="200" alt="Home Screen"> | <img src="screenshots/detail.png" width="200" alt="Detail Screen"> | <img src="screenshots/my_courses.png" width="200" alt="My Courses"> |

*(Nếu chưa có ảnh trong thư mục screenshots, giao diện sẽ hiển thị text thay thế)*

---

## 4. ✅ Các chức năng đã hoàn thiện (Checklist)

Dự án đã hoàn thành **100%** các yêu cầu của đề bài:

### 🔹 Quản lý dữ liệu & Kết nối
- [x] **Firebase Integration:** Kết nối thành công Firestore.
- [x] **Data Seeding (Tính năng đặc biệt):** Tích hợp nút tạo nhanh dữ liệu mẫu gồm:
    - **5 Students** (Đầy đủ thông tin cá nhân).
    - **12 Courses** (Phân bổ theo Programming, Design, Business).
    - **10 Enrollments** (Đa dạng trạng thái Completed, Ongoing).

### 🔹 Chức năng người dùng (User Features)
- [x] **Xem danh sách khóa học:** Hiển thị dạng thẻ (Card) với ảnh, tên, giá, rating.
- [x] **Tìm kiếm (Search):** Tìm kiếm khóa học theo tên (Real-time).
- [x] **Bộ lọc (Filter):** Lọc khóa học theo danh mục (Programming, Design, Business).
- [x] **Xem chi tiết:** Hiển thị đầy đủ thông tin giảng viên, số bài học, mô tả.
- [x] **Khóa học của tôi:** Xem danh sách các khóa đã đăng ký.

### 🔹 Kỹ thuật lập trình
- [x] **Real-time Updates:** Sử dụng `StreamBuilder` để giao diện tự cập nhật khi DB thay đổi.
- [x] **Error Handling:** Xử lý các trạng thái Loading, Error, Empty Data.

---

## 5. 📂 Cấu trúc dự án
Source code được tổ chức theo mô hình rõ ràng, dễ bảo trì:
lib/ ├── models/ # Chứa các Class mô tả dữ liệu (Course, Student) │ ├── course_model.dart │ └── student_model.dart ├── screens/ # Chứa các màn hình giao diện (UI) │ ├── home_screen.dart # Màn hình chính │ ├── course_detail_screen.dart # Màn hình chi tiết │ └── my_courses_screen.dart # Màn hình khóa học đã đăng ký ├── utils/ # Các tiện ích dùng chung │ └── globals.dart └── main.dart # Điểm khởi chạy ứng dụng & Hàm Seed Data

## 6. 🗄 Cấu trúc Cơ sở dữ liệu (Firestore Schema)

## Collection 1: students
studentId (String, Document ID): ID duy nhất của học viên
email (String): Email đăng nhập
fullName (String): Họ và tên đầy đủ
phoneNumber (String): Số điện thoại
dateOfBirth (Timestamp): Ngày sinh
gender (String): Giới tính ("male", "female", "other")
avatarUrl (String, nullable): URL ảnh đại diện
createdAt (Timestamp): Thời gian tạo tài khoản
isActive (Boolean): Trạng thái tài khoản

## Collection 2: courses
courseId (String, Document ID): ID duy nhất của khóa học
title (String): Tiêu đề khóa học
description (String): Mô tả khóa học
instructor (String): Tên giảng viên
category (String): Danh mục ("Programming", "Design", "Business", "Language", "Music")
level (String): Cấp độ ("Beginner", "Intermediate", "Advanced")
duration (Integer): Thời lượng (giờ)
price (Double): Giá khóa học
de_thi_thu_firebase_03.md 2025-12-31
2 / 5
imageUrl (String): URL hình ảnh khóa học
rating (Double): Đánh giá trung bình (0.0 - 5.0)
studentCount (Integer): Số lượng học viên đã đăng ký
lessonCount (Integer): Số lượng bài học
isPublished (Boolean): Đã xuất bản chưa
createdAt (Timestamp): Thời gian tạo khóa học

## Collection 3: enrollments
enrollmentId (String, Document ID): ID duy nhất của đăng ký
studentId (String): ID của học viên (reference đến students)
courseId (String): ID của khóa học (reference đến courses)
enrollmentDate (Timestamp): Ngày đăng ký
progress (Integer): Tiến độ học tập (0-100%)
completedLessons (Array of Strings): Danh sách ID bài học đã hoàn thành
status (String): Trạng thái ("active", "completed", "dropped")
lastAccessedAt (Timestamp, nullable): Lần truy cập cuối
certificateIssued (Boolean): Đã cấp chứng chỉ chưa (chỉ true khi progress = 100%)
notes (String, nullable): Ghi chú

## Về quan hệ:
Một student có thể đăng ký nhiều course (quan hệ nhiều-nhiều qua enrollments)
Một course có thể có nhiều student đăng ký
Khi đăng ký khóa học: tăng studentCount của course
Khi hoàn thành khóa học (progress = 100%): certificateIssued = true
completedLessons là array chứa ID các bài học đã học xong


---

## 7. 🚀 Hướng dẫn cài đặt & Chạy dự án

**Lưu ý quan trọng:** Để chạy được dự án, cần có file cấu hình Firebase.

1.  **Clone repository:**
    ```bash
    git clone [https://github.com/phuongtech24/2251172459_NguyenKhacNamPhuong.git](https://github.com/phuongtech24/2251172459_NguyenKhacNamPhuong.git)
    ```
2.  **Cài đặt thư viện:**
    ```bash
    flutter pub get
    ```
3.  **Cấu hình Firebase:**
    * Đảm bảo file `google-services.json` đã được đặt trong thư mục `android/app/`.
    * *(File này đã được include sẵn trong repo phục vụ việc chấm bài).*
4.  **Chạy ứng dụng:**
    ```bash
    flutter run
    ```
5.  **Tạo dữ liệu mẫu (Nếu DB trống):**
    * Tại màn hình chính, bấm nút **"Import Data"** (màu đỏ) ở góc dưới để nạp dữ liệu mẫu vào Firestore.

---
*Cảm ơn Thầy đã xem bài tập lớn của em!* ❤️
