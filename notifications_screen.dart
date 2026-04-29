import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/ai_service.dart';
import '../utils/theme.dart';
import '../widgets/ai_suggestion_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AiService _aiService = AiService();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);
    try {
      final taskProvider = context.read<TaskProvider>();
      final history = await taskProvider.getTaskHistoryForAI();
      _suggestions = await _aiService.getSuggestions(history);
    } catch (_) {
      _suggestions = [
        {'title': 'Time for a break! 🧘', 'subtitle': "You've been active for a while. A 5-minute break can boost focus.", 'icon': 'health'},
        {'title': 'Review your tasks 📋', 'subtitle': 'Check your upcoming tasks and prioritize what matters most.', 'icon': 'work'},
        {'title': 'Stay hydrated! 💧', 'subtitle': "Don't forget to drink water. Hydration helps concentration.", 'icon': 'health'},
        {'title': 'Connect with someone 📱', 'subtitle': 'A quick call to a friend or family member can brighten your day.', 'icon': 'social'},
      ];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                const Text('AI Suggestions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: _loadSuggestions,
                  icon: const Icon(Icons.refresh_rounded, color: AppTheme.textHint),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: Text('Smart suggestions based on your habits', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _suggestions.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 56, color: AppTheme.primaryLight.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text('No suggestions yet', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
                      ]))
                    : RefreshIndicator(
                        onRefresh: _loadSuggestions,
                        color: AppTheme.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: _suggestions.length,
                          itemBuilder: (context, i) {
                            final s = _suggestions[i];
                            return AiSuggestionCard(
                              title: s['title'] ?? '',
                              subtitle: s['subtitle'] ?? '',
                              iconType: s['icon'] ?? 'reminder',
                              onDismiss: () => setState(() => _suggestions.removeAt(i)),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
