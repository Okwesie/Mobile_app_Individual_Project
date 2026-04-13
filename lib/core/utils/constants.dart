abstract final class AppConstants {
  // DB
  static const String dbName = 'adventure_logger.db';
  static const String tableLog = 'logs';
  static const int dbVersion = 1;

  // Hive boxes
  static const String settingsBox = 'settings';
  static const String keyEmergencyContact = 'emergency_contact';
  static const String keyTtsRate = 'tts_rate';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Notifications
  static const int notifSavedId = 1001;
  static const String notifChannelId = 'adventure_logger_main';
  static const String notifChannelName = 'Adventure Logger';
  static const String notifChannelDesc = 'Log save confirmations and alerts';

  // Misc
  static const double defaultTtsRate = 0.5;
  static const String defaultEmergencyContact = '';
}
