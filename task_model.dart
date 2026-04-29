import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final DateTime? dueTime;
  final double? lat;
  final double? lng;
  final double? radius;
  final String? locationLabel;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.category = 'other',
    this.dueTime,
    this.lat,
    this.lng,
    this.radius,
    this.locationLabel,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      category: data['category'] ?? 'other',
      dueTime: data['dueTime'] != null
          ? (data['dueTime'] as Timestamp).toDate()
          : null,
      lat: data['lat']?.toDouble(),
      lng: data['lng']?.toDouble(),
      radius: data['radius']?.toDouble(),
      locationLabel: data['locationLabel'],
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'dueTime': dueTime != null ? Timestamp.fromDate(dueTime!) : null,
      'lat': lat,
      'lng': lng,
      'radius': radius,
      'locationLabel': locationLabel,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    DateTime? dueTime,
    double? lat,
    double? lng,
    double? radius,
    String? locationLabel,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      dueTime: dueTime ?? this.dueTime,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radius: radius ?? this.radius,
      locationLabel: locationLabel ?? this.locationLabel,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get hasLocation => lat != null && lng != null;

  bool get isOverdue =>
      dueTime != null && dueTime!.isBefore(DateTime.now()) && !isCompleted;

  Duration? get timeRemaining =>
      dueTime?.difference(DateTime.now());

  @override
  String toString() => 'TaskModel(id: $id, title: $title, completed: $isCompleted)';
}
