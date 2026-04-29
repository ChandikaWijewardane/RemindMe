import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Derived task lists
  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _allTasks.where((t) {
      if (t.dueTime == null) {
        return t.createdAt.isAfter(startOfDay) &&
            t.createdAt.isBefore(endOfDay);
      }
      return t.dueTime!.isAfter(startOfDay) && t.dueTime!.isBefore(endOfDay);
    }).toList();
  }

  List<TaskModel> get remainingToday =>
      todayTasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get completedTasks =>
      _allTasks.where((t) => t.isCompleted).toList();

  List<TaskModel> get scheduledTasks =>
      _allTasks.where((t) => t.dueTime != null && !t.isCompleted).toList()
        ..sort((a, b) => a.dueTime!.compareTo(b.dueTime!));

  List<TaskModel> get flaggedTasks =>
      _allTasks.where((t) => t.isOverdue).toList();

  List<TaskModel> get locationTasks =>
      _allTasks.where((t) => t.hasLocation && !t.isCompleted).toList();

  List<TaskModel> get incompleteTasks =>
      _allTasks.where((t) => !t.isCompleted).toList();

  int get totalTasksCreated => _allTasks.length;
  int get totalCompleted => completedTasks.length;
  double get focusScore =>
      totalTasksCreated > 0 ? (totalCompleted / totalTasksCreated) * 100 : 0;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Initialize - listen to tasks
  void listenToTasks() {
    if (_uid == null) return;

    _isLoading = true;
    notifyListeners();

    _firestoreService.streamAllTasks(_uid!).listen(
      (tasks) {
        _allTasks = tasks;
        _isLoading = false;
        _error = null;
        notifyListeners();

        // Start geofence monitoring with location tasks
        _startGeofencing();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Add task
  Future<void> addTask({
    required String title,
    String subtitle = '',
    String category = 'other',
    DateTime? dueTime,
    double? lat,
    double? lng,
    double? radius,
    String? locationLabel,
  }) async {
    if (_uid == null) return;

    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      subtitle: subtitle,
      category: category,
      dueTime: dueTime,
      lat: lat,
      lng: lng,
      radius: radius ?? 500.0,
      locationLabel: locationLabel,
      createdAt: DateTime.now(),
    );

    await _firestoreService.addTask(_uid!, task);
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    if (_uid == null) return;
    await _firestoreService.updateTask(_uid!, task);
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    if (_uid == null) return;
    await _firestoreService.deleteTask(_uid!, taskId);
  }

  // Toggle completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (_uid == null) return;
    await _firestoreService.toggleTaskCompletion(_uid!, taskId, isCompleted);

    if (isCompleted) {
      final task = _allTasks.firstWhere((t) => t.id == taskId,
          orElse: () => TaskModel(id: '', title: '', createdAt: DateTime.now()));
      if (task.id.isNotEmpty) {
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '✅ Task Completed!',
          body: 'Great job completing "${task.title}"! Keep it up! 🎉',
        );
      }
    }
  }

  // Create task from AI response
  Future<void> createTaskFromAI(Map<String, dynamic> taskData) async {
    DateTime? dueTime;
    if (taskData['dueTime'] != null) {
      try {
        dueTime = DateTime.parse(taskData['dueTime']);
      } catch (_) {}
    }

    await addTask(
      title: taskData['title'] ?? 'New Task',
      subtitle: taskData['subtitle'] ?? '',
      category: taskData['category'] ?? 'other',
      dueTime: dueTime,
      lat: taskData['lat']?.toDouble(),
      lng: taskData['lng']?.toDouble(),
      locationLabel: taskData['locationLabel'],
    );
  }

  // Get task history for AI
  Future<List<Map<String, dynamic>>> getTaskHistoryForAI() async {
    return _allTasks.take(30).map((t) => {
          'title': t.title,
          'category': t.category,
          'completed': t.isCompleted,
          'dueTime': t.dueTime?.toIso8601String(),
          'hasLocation': t.hasLocation,
          'locationLabel': t.locationLabel,
        }).toList();
  }

  // Start geofence monitoring
  void _startGeofencing() {
    final tasks = locationTasks;
    if (tasks.isNotEmpty) {
      _locationService.startGeofenceMonitoring(
        tasks,
        (task) {
          _notificationService.showGeofenceNotification(
            taskTitle: task.title,
            locationLabel: task.locationLabel ?? 'this location',
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
