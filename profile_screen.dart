import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
import '../utils/theme.dart';
import '../widgets/focus_score_ring.dart';
import 'settings_screen.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  icon: const Icon(Icons.settings_rounded, color: AppTheme.textHint),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                    ),
                    child: userProvider.photoUrl != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(userProvider.photoUrl!, fit: BoxFit.cover))
                        : const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 14),
                  Text(userProvider.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    userProvider.user?.mood ?? 'Feeling productive! 🚀',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Focus Score
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  const Text('Focus Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 20),
                  FocusScoreRing(score: taskProvider.focusScore, size: 140, strokeWidth: 12, label: 'Focus'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatColumn(value: '${taskProvider.totalCompleted}', label: 'Completed'),
                      Container(width: 1, height: 36, color: Colors.grey.shade200),
                      _StatColumn(value: '${taskProvider.totalTasksCreated}', label: 'Total'),
                      Container(width: 1, height: 36, color: Colors.grey.shade200),
                      _StatColumn(value: '${taskProvider.remainingToday.length}', label: 'Remaining'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Stats Cards
            Row(
              children: [
                Expanded(child: _QuickStatCard(icon: Icons.today_rounded, label: 'Today', value: '${taskProvider.todayTasks.length}', color: AppTheme.info)),
                const SizedBox(width: 12),
                Expanded(child: _QuickStatCard(icon: Icons.flag_rounded, label: 'Overdue', value: '${taskProvider.flaggedTasks.length}', color: AppTheme.error)),
                const SizedBox(width: 12),
                Expanded(child: _QuickStatCard(icon: Icons.location_on_rounded, label: 'Location', value: '${taskProvider.locationTasks.length}', color: AppTheme.primaryLight)),
              ],
            ),
            const SizedBox(height: 28),

            // Sign out
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await userProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: const BorderSide(color: AppTheme.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ]);
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _QuickStatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
      ]),
    );
  }
}
