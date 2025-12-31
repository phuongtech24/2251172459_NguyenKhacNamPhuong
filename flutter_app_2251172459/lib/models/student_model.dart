import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String studentId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String? avatarUrl; // Nullable
  final DateTime createdAt;
  final bool isActive;

  StudentModel({
    required this.studentId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    this.avatarUrl,
    required this.createdAt,
    required this.isActive,
  });

  // Chuyển từ Map (Firestore) sang Object (Flutter)
  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      studentId: id, // Lấy ID từ document ID
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      // Xử lý chuyển đổi Timestamp sang DateTime
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      gender: map['gender'] ?? 'other',
      avatarUrl: map['avatarUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Chuyển từ Object (Flutter) sang Map (Firestore) để lưu
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth), // Chuyển ngược lại
      'gender': gender,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}