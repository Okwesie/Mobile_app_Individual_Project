import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:adventure_logger/core/utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _box;
  bool _ready = false;

  bool get ready => _ready;

  String get emergencyContact =>
      _box.get(AppConstants.keyEmergencyContact,
          defaultValue: AppConstants.defaultEmergencyContact) as String;

  double get ttsRate =>
      (_box.get(AppConstants.keyTtsRate,
          defaultValue: AppConstants.defaultTtsRate) as num)
          .toDouble();

  bool get notificationsEnabled =>
      _box.get(AppConstants.keyNotificationsEnabled, defaultValue: true)
          as bool;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(AppConstants.settingsBox);
    _ready = true;
    notifyListeners();
  }

  Future<void> setEmergencyContact(String value) async {
    await _box.put(AppConstants.keyEmergencyContact, value);
    notifyListeners();
  }

  Future<void> setTtsRate(double value) async {
    await _box.put(AppConstants.keyTtsRate, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _box.put(AppConstants.keyNotificationsEnabled, value);
    notifyListeners();
  }
}
