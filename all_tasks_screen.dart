import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/theme.dart';
import '../widgets/task_card.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Today', 'Scheduled', 'Flagged', 'Location', 'Completed', 'All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskModel> _getTasksForTab(TaskProvider p, int i) {
    switch (i) {
      case 0: return p.todayTasks.where((t) => !t.isCompleted).toList();
      case 1: return p.scheduledTasks;
      case 2: return p.flaggedTasks;
      case 3: return p.locationTasks;
      case 4: return p.completedTasks;
      default: return p.allTasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TaskProvider>();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                const Text('All Tasks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('${tp.allTasks.length} total', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController, isScrollable: true, tabAlignment: TabAlignment.start,
              labelColor: AppTheme.primaryColor, unselectedLabelColor: AppTheme.textHint,
              indicatorColor: AppTheme.primaryColor, indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (index) {
                final tasks = _getTasksForTab(tp, index);
                if (tp.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                if (tasks.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.checklist_rounded, size: 56, color: AppTheme.primaryLight.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(index == 2 ? 'No overdue tasks — great job! 🎉' : 'No tasks here yet', style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
                  ]));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    return TaskCard(task: task, onToggle: () => tp.toggleTaskCompletion(task.id, !task.isCompleted), onDelete: () => tp.deleteTask(task.id));
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
