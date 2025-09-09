import 'package:hive_ce/hive.dart';

class UserActivityTracker {
  static const String _boxName = 'user_activity';
  static const String _lastActiveKey = 'lastActive';

  static Future<void> markActive() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> wasActiveWithin(Duration window) async {
    final box = await Hive.openBox(_boxName);
    final lastActive = box.get(_lastActiveKey) as int?;
    if (lastActive == null) return false;
    final lastActiveTime = DateTime.fromMillisecondsSinceEpoch(lastActive);
    return DateTime.now().difference(lastActiveTime) <= window;
  }
}
