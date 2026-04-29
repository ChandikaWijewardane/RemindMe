import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? mood;
  final int tasksCompletedToday;
  final int totalTasksToday;
  final double focusScore;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.mood,
    this.tasksCompletedToday = 0,
    this.totalTasksToday = 0,
    this.focusScore = 0.0,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      mood: data['mood'],
      tasksCompletedToday: data['tasksCompletedToday'] ?? 0,
      totalTasksToday: data['totalTasksToday'] ?? 0,
      focusScore: (data['focusScore'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'mood': mood,
      'tasksCompletedToday': tasksCompletedToday,
      'totalTasksToday': totalTasksToday,
      'focusScore': focusScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? mood,
    int? tasksCompletedToday,
    int? totalTasksToday,
    double? focusScore,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      mood: mood ?? this.mood,
      tasksCompletedToday: tasksCompletedToday ?? this.tasksCompletedToday,
      totalTasksToday: totalTasksToday ?? this.totalTasksToday,
      focusScore: focusScore ?? this.focusScore,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
