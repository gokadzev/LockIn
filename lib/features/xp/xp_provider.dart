import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/features/xp/xp_models.dart';
import 'package:lockin/features/xp/xp_service.dart';

class XPNotifier extends StateNotifier<XPProfile> {
  XPNotifier(this.service, this.hiveBox) : super(service.profile);
  final XPService service;
  final Box<XPProfile>? hiveBox;

  XPProfile get profile => state;
  int get xp => state.xp;
  int get level => state.level;
  List<Reward> get unlockedRewards => state.unlockedRewards;

  void addXP(int amount) {
    try {
      service.addXP(amount);
      state = service.profile;
      hiveBox?.put('profile', state);
    } catch (e, stackTrace) {
      debugPrint('Error adding XP: $e');
      debugPrint('StackTrace: $stackTrace');
      // State remains unchanged on error
    }
  }

  Future<void> consumeStreakSaver(int xpLoss) async {
    final profile = state;
    final updatedProfile = XPProfile(
      xp: (profile.xp - xpLoss).clamp(0, 1000000),
      level: profile.level,
      unlockedRewards: profile.unlockedRewards,
    );
    service.profile = updatedProfile;
    state = updatedProfile;
    await hiveBox?.put('profile', updatedProfile);
  }

  static Future<XPNotifier> create() async {
    Box<XPProfile>? box;
    try {
      if (Hive.isBoxOpen('xp_profile')) {
        box = Hive.box<XPProfile>('xp_profile');
      } else {
        box = await Hive.openBox<XPProfile>('xp_profile');
      }
    } catch (e, stackTrace) {
      debugPrint('Error opening XP profile box: $e');
      debugPrint('StackTrace: $stackTrace');
      box = null;
    }
    final profile =
        box?.get('profile') ??
        const XPProfile(xp: 0, level: 1, unlockedRewards: []);
    return XPNotifier(XPService(profile), box);
  }
}

final xpNotifierProvider = FutureProvider<XPNotifier>((ref) async {
  return XPNotifier.create();
});
