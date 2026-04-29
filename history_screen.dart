import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final completed = taskProvider.completedTasks;

    // Group by date
    final Map<String, List<TaskModel>> grouped = {};
    for (final task in completed) {
      final date = task.completedAt ?? task.createdAt;
      final key = _getDateLabel(date);
      grouped.putIfAbsent(key, () => []).add(task);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: completed.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.history_rounded, size: 56, color: AppTheme.primaryLight.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              const Text('No completed tasks yet', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              const Text('Complete some tasks to see your history!', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final dateKey = grouped.keys.elementAt(index);
                final tasks = grouped[dateKey]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12, top: index > 0 ? 16 : 0),
                      child: Text(dateKey, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                    ),
                    ...tasks.map((task) => _HistoryTaskRow(task: task)),
                  ],
                );
              },
            ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(date);
  }
}

class _HistoryTaskRow extends StatelessWidget {
  final TaskModel task;
  const _HistoryTaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.categoryColors[task.category] ?? AppTheme.primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.check_rounded, color: AppTheme.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.lineThrough)),
            if (task.subtitle.isNotEmpty)
              Text(task.subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textHint), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(task.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: categoryColor)),
            ),
            const SizedBox(height: 4),
            Text(
              task.completedAt != null ? DateFormat('h:mm a').format(task.completedAt!) : '',
              style: const TextStyle(fontSize: 10, color: AppTheme.textHint),
            ),
          ]),
        ],
      ),
    );
  }
}
