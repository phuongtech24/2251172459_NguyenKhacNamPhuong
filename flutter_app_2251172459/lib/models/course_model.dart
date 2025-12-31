import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String courseId;
  final String title;
  final String description;
  final String instructor;
  final String category;
  final String level;
  final int duration;
  final double price;
  final String imageUrl;
  final double rating;
  final int studentCount;
  final int lessonCount;
  final bool isPublished;
  final DateTime createdAt;

  CourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructor,
    required this.category,
    required this.level,
    required this.duration,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.studentCount,
    required this.lessonCount,
    required this.isPublished,
    required this.createdAt,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      courseId: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructor: map['instructor'] ?? '',
      category: map['category'] ?? '',
      level: map['level'] ?? 'Beginner',
      duration: map['duration'] ?? 0,
      // Xử lý an toàn cho double (tránh lỗi int -> double)
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      studentCount: map['studentCount'] ?? 0,
      lessonCount: map['lessonCount'] ?? 0,
      isPublished: map['isPublished'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'instructor': instructor,
      'category': category,
      'level': level,
      'duration': duration,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'studentCount': studentCount,
      'lessonCount': lessonCount,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}