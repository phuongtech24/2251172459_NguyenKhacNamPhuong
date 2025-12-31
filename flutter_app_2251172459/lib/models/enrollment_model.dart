import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String enrollmentId;
  final String studentId;
  final String courseId;
  final DateTime enrollmentDate;
  final int progress; // 0-100%
  final List<String> completedLessons; // Array of IDs
  final String status; // "active", "completed", "dropped"
  final DateTime? lastAccessedAt; // Nullable
  final bool certificateIssued;
  final String? notes; // Nullable

  EnrollmentModel({
    required this.enrollmentId,
    required this.studentId,
    required this.courseId,
    required this.enrollmentDate,
    required this.progress,
    required this.completedLessons,
    required this.status,
    this.lastAccessedAt,
    required this.certificateIssued,
    this.notes,
  });

  factory EnrollmentModel.fromMap(Map<String, dynamic> map, String id) {
    return EnrollmentModel(
      enrollmentId: id,
      studentId: map['studentId'] ?? '',
      courseId: map['courseId'] ?? '',
      enrollmentDate: (map['enrollmentDate'] as Timestamp).toDate(),
      progress: map['progress'] ?? 0,
      // Xử lý mảng an toàn
      completedLessons: List<String>.from(map['completedLessons'] ?? []),
      status: map['status'] ?? 'active',
      // Xử lý nullable timestamp
      lastAccessedAt: map['lastAccessedAt'] != null 
          ? (map['lastAccessedAt'] as Timestamp).toDate() 
          : null,
      certificateIssued: map['certificateIssued'] ?? false,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enrollmentId': enrollmentId,
      'studentId': studentId,
      'courseId': courseId,
      'enrollmentDate': Timestamp.fromDate(enrollmentDate),
      'progress': progress,
      'completedLessons': completedLessons,
      'status': status,
      'lastAccessedAt': lastAccessedAt != null 
          ? Timestamp.fromDate(lastAccessedAt!) 
          : null,
      'certificateIssued': certificateIssued,
      'notes': notes,
    };
  }
}