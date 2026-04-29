import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import '../utils/theme.dart';
import '../widgets/task_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'all_tasks_screen.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _greetingController;
  late final Animation<double> _greetingFade;
  late final Animation<Offset> _greetingSlide;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _greetingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeOut),
    );
    _greetingSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _greetingController, curve: Curves.easeOut));
    _greetingController.forward();

    _screens.addAll([
      _HomeDashboard(
        greetingFade: _greetingFade,
        greetingSlide: _greetingSlide,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      const NotificationsScreen(),
      const ChatScreen(),
      const AllTasksScreen(),
      const ProfileScreen(),
    ]);
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  final Animation<double> greetingFade;
  final Animation<Offset> greetingSlide;
  final ValueChanged<int> onNavigate;

  const _HomeDashboard({
    required this.greetingFade,
    required this.greetingSlide,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final remaining = taskProvider.remainingToday;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header / Greeting
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: greetingFade,
              child: SlideTransition(
                position: greetingSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${userProvider.getGreeting()},',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${userProvider.displayName}! 👋',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Profile avatar
                          GestureDetector(
                            onTap: () => onNavigate(4),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.primaryColor.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: userProvider.photoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        userProvider.photoUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'How can I help you today?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick Access
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  _QuickAccessCard(
                    icon: Icons.add_task_rounded,
                    label: 'Add Task',
                    color: AppTheme.primaryColor,
                    onTap: () => _showAddTaskDialog(context),
                  ),
                  const SizedBox(width: 12),
                  _QuickAccessCard(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Chat',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => onNavigate(2),
                  ),
                  const SizedBox(width: 12),
                  _QuickAccessCard(
                    icon: Icons.history_rounded,
                    label: 'History',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _QuickAccessCard(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Stats summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Focus Score',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${taskProvider.focusScore.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 50, color: Colors.white24),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatItem(
                              label: 'Completed',
                              value: '${taskProvider.totalCompleted}',
                            ),
                            const SizedBox(height: 8),
                            _StatItem(
                              label: 'Remaining',
                              value: '${remaining.length}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Remaining Today header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Row(
                children: [
                  const Text(
                    'Remaining Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => onNavigate(3),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tasks list
          if (remaining.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.celebration_rounded,
                        size: 56,
                        color: AppTheme.primaryLight.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "You're all caught up! 🎉",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'No remaining tasks for today',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showAddTaskDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Add a Task'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = remaining[index];
                    return TaskCard(
                      task: task,
                      onToggle: () {
                        taskProvider.toggleTaskCompletion(
                            task.id, !task.isCompleted);
                      },
                      onDelete: () {
                        taskProvider.deleteTask(task.id);
                      },
                    );
                  },
                  childCount: remaining.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    String selectedCategory = 'personal';
    DateTime? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXLarge),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'New Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'What do you need to do?',
                        prefixIcon:
                            Icon(Icons.edit_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        hintText: 'Add details (optional)',
                        prefixIcon:
                            Icon(Icons.notes_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['personal', 'work', 'health', 'shopping',
                          'social', 'education'].map((cat) {
                        final isSelected = selectedCategory == cat;
                        final color = AppTheme.categoryColors[cat]!;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => selectedCategory = cat);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.15)
                                  : AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppTheme.categoryIcons[cat],
                                  size: 16,
                                  color: isSelected
                                      ? color
                                      : AppTheme.textHint,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat[0].toUpperCase() +
                                      cat.substring(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? color
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Time picker
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          if (!ctx.mounted) return;
                          final time = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setModalState(() {
                              selectedTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 20, color: AppTheme.primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              selectedTime != null
                                  ? '${selectedTime!.day}/${selectedTime!.month}/${selectedTime!.year} at ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Set due date & time',
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedTime != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;
                          context.read<TaskProvider>().addTask(
                                title: titleController.text.trim(),
                                subtitle: subtitleController.text.trim(),
                                category: selectedCategory,
                                dueTime: selectedTime,
                              );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Add Task'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: color.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
