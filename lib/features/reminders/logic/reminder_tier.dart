import 'package:hydrowflow/features/reminders/data/models/reminder_sound.dart';

/// What free users get vs Premium. Saved settings are kept as chosen, so a
/// returning Premium user gets their old setup back; free users only see the
/// effective (downgraded) values.
class ReminderTier {
  static const List<int> freeIntervals = [60, 120];
  static const List<int> allIntervals = [30, 45, 60, 90, 120, 180];

  static bool isIntervalFree(int minutes) => freeIntervals.contains(minutes);

  static int effectiveInterval(int saved, {required bool premium}) =>
      premium || isIntervalFree(saved) ? saved : 60;

  static String effectiveSound(String saved, {required bool premium}) =>
      premium ? saved : ReminderSound.systemDefaultId;
}
