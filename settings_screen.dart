import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _fontSize = 14;
  bool _reminderAlerts = true;
  bool _locationAlerts = true;
  bool _dndMode = false;
  bool _aiRememberHabits = true;
  String _reminderType = 'Notification';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble(AppConstants.prefFontSize) ?? 14;
      _reminderAlerts = prefs.getBool(AppConstants.prefReminderAlerts) ?? true;
      _locationAlerts = prefs.getBool(AppConstants.prefLocationAlerts) ?? true;
      _dndMode = prefs.getBool(AppConstants.prefDndMode) ?? false;
      _aiRememberHabits = prefs.getBool(AppConstants.prefAiRememberHabits) ?? true;
      _reminderType = prefs.getString(AppConstants.prefReminderType) ?? 'Notification';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) prefs.setBool(key, value);
    if (value is double) prefs.setDouble(key, value);
    if (value is String) prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          _SectionHeader(title: 'Account'),
          _SettingsCard(children: [
            _SettingsTile(
              icon: Icons.person_rounded, color: AppTheme.primaryColor,
              title: 'Edit Profile', subtitle: userProvider.displayName,
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint),
              onTap: () => _showEditProfileDialog(context, userProvider),
            ),
          ]),
          const SizedBox(height: 20),

          // Appearance
          _SectionHeader(title: 'Appearance'),
          _SettingsCard(children: [
            _SettingsTile(
              icon: Icons.text_fields_rounded, color: const Color(0xFF8B5CF6),
              title: 'Font Size', subtitle: '${_fontSize.toInt()}px',
              trailing: SizedBox(
                width: 140,
                child: Slider(
                  value: _fontSize, min: 12, max: 20, divisions: 4,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) { setState(() => _fontSize = v); _saveSetting(AppConstants.prefFontSize, v); },
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // Notifications
          _SectionHeader(title: 'Notifications'),
          _SettingsCard(children: [
            _SettingsTile(
              icon: Icons.notifications_rounded, color: AppTheme.warning,
              title: 'Reminder Alerts', subtitle: 'Get notified about upcoming tasks',
              trailing: Switch(
                value: _reminderAlerts, activeTrackColor: AppTheme.primaryColor,
                onChanged: (v) { setState(() => _reminderAlerts = v); _saveSetting(AppConstants.prefReminderAlerts, v); },
              ),
            ),
            const Divider(height: 1, indent: 56),
            _SettingsTile(
              icon: Icons.location_on_rounded, color: AppTheme.info,
              title: 'Location-based Alerts', subtitle: 'Notify when near task locations',
              trailing: Switch(
                value: _locationAlerts, activeTrackColor: AppTheme.primaryColor,
                onChanged: (v) { setState(() => _locationAlerts = v); _saveSetting(AppConstants.prefLocationAlerts, v); },
              ),
            ),
            const Divider(height: 1, indent: 56),
            _SettingsTile(
              icon: Icons.do_not_disturb_on_rounded, color: AppTheme.error,
              title: 'Do Not Disturb', subtitle: 'Pause all notifications',
              trailing: Switch(
                value: _dndMode, activeTrackColor: AppTheme.primaryColor,
                onChanged: (v) { setState(() => _dndMode = v); _saveSetting(AppConstants.prefDndMode, v); },
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // AI Settings
          _SectionHeader(title: 'AI & Privacy'),
          _SettingsCard(children: [
            _SettingsTile(
              icon: Icons.auto_awesome_rounded, color: const Color(0xFF8B5CF6),
              title: 'AI Remembers Habits', subtitle: 'Allow AI to learn from your patterns',
              trailing: Switch(
                value: _aiRememberHabits, activeTrackColor: AppTheme.primaryColor,
                onChanged: (v) { setState(() => _aiRememberHabits = v); _saveSetting(AppConstants.prefAiRememberHabits, v); },
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // Reminder Type
          _SectionHeader(title: 'Reminder Type'),
          _SettingsCard(children: [
            ...['Notification', 'Call', 'Message', 'Alarm'].map((type) {
              final icons = {'Notification': Icons.notifications_rounded, 'Call': Icons.call_rounded, 'Message': Icons.message_rounded, 'Alarm': Icons.alarm_rounded};
              return Column(children: [
                _SettingsTile(
                  icon: icons[type]!, color: AppTheme.primaryColor,
                  title: type, subtitle: '',
                  trailing: Icon(_reminderType == type ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: _reminderType == type ? AppTheme.primaryColor : AppTheme.textHint),
                  onTap: () { setState(() => _reminderType = type); _saveSetting(AppConstants.prefReminderType, type); },
                ),
                if (type != 'Alarm') const Divider(height: 1, indent: 56),
              ]);
            }),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    final nameController = TextEditingController(text: userProvider.displayName);
    final moodController = TextEditingController(text: userProvider.user?.mood ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile', style: TextStyle(fontSize: 18)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_rounded, size: 20))),
          const SizedBox(height: 12),
          TextField(controller: moodController, decoration: const InputDecoration(labelText: 'Mood / Tagline', prefixIcon: Icon(Icons.emoji_emotions_rounded, size: 20))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              userProvider.updateProfile(name: nameController.text.trim(), mood: moodController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(AppTheme.radiusLarge), boxShadow: AppTheme.cardShadow),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
            ])),
            trailing,
          ],
        ),
      ),
    );
  }
}
