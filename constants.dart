class AppConstants {
  // App Info
  static const String appName = 'RemindMe AI';
  static const String appTagline = 'Your ADHD-Friendly Personal Assistant';

  // Gemini API
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // System prompt for AI Chat
  static const String aiSystemPrompt = '''
You are RemindMe AI, a friendly and supportive assistant designed specifically for people with ADHD and executive dysfunction. Your role is to:

1. Help users create tasks, set reminders, and manage their day
2. Extract task details from natural language: title, time, location, category
3. Respond in a warm, encouraging, non-judgmental tone
4. Keep responses concise and actionable (ADHD-friendly)
5. Celebrate small wins and progress
6. Offer gentle nudges without being pushy

When a user wants to create a task, respond with the task details in this JSON format at the end of your message:
[TASK_JSON]{"title":"...","subtitle":"...","category":"...","dueTime":"ISO8601","locationLabel":"...","lat":0.0,"lng":0.0}[/TASK_JSON]

Categories: work, personal, health, shopping, social, finance, education, other
''';

  // Suggestion prompt
  static const String suggestionPrompt = '''
Based on the user's task history and patterns, generate 3-5 smart suggestions.
Each suggestion should be practical, encouraging, and relevant.
Format each suggestion as a JSON array:
[{"title":"...","subtitle":"...","icon":"shopping|health|social|work|reminder"}]
''';

  // Geofence
  static const double geofenceRadius = 500.0; // meters

  // SharedPreferences Keys
  static const String prefFontSize = 'font_size';
  static const String prefColorTheme = 'color_theme';
  static const String prefReminderAlerts = 'reminder_alerts';
  static const String prefLocationAlerts = 'location_alerts';
  static const String prefDndMode = 'dnd_mode';
  static const String prefAiRememberHabits = 'ai_remember_habits';
  static const String prefReminderType = 'reminder_type';
  static const String prefUserName = 'user_name';

  // Task Categories
  static const List<String> categories = [
    'work',
    'personal',
    'health',
    'shopping',
    'social',
    'finance',
    'education',
    'other',
  ];
}
