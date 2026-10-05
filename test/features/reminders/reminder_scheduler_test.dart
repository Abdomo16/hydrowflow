import 'package:flutter_test/flutter_test.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_scheduler.dart';

void main() {
  List<ReminderSlot> plan({
    required DateTime now,
    int interval = 60,
    String wake = '08:00',
    String sleep = '22:00',
    bool goalReached = false,
    DateTime? lastDrinkAt,
    int daysAhead = 3,
    int maxCount = 60,
  }) {
    return planReminders(
      intervalMinutes: interval,
      wakeTime: wake,
      sleepTime: sleep,
      now: now,
      goalReachedToday: goalReached,
      lastDrinkAt: lastDrinkAt,
      daysAhead: daysAhead,
      maxCount: maxCount,
    );
  }

  test('before wake: first reminder is one interval after wake', () {
    final slots = plan(now: DateTime(2026, 10, 5, 6, 0), daysAhead: 1);

    expect(slots.first.at, DateTime(2026, 10, 5, 9, 0));
    expect(slots.last.at, DateTime(2026, 10, 5, 21, 0));
    expect(slots.length, 13);
    expect(slots.every((s) => s.isCurrentDay), isTrue);
  });

  test('mid-day without drinks: stays on the wake-anchored grid', () {
    final slots = plan(now: DateTime(2026, 10, 5, 10, 30), daysAhead: 1);

    expect(slots.first.at, DateTime(2026, 10, 5, 11, 0));
  });

  test('a drink restarts the countdown', () {
    final slots = plan(
      now: DateTime(2026, 10, 5, 10, 56),
      lastDrinkAt: DateTime(2026, 10, 5, 10, 55),
      daysAhead: 1,
    );

    expect(slots.first.at, DateTime(2026, 10, 5, 11, 55));
    expect(slots[1].at, DateTime(2026, 10, 5, 12, 55));
  });

  test('overdue drink anchor skips ahead to the next future slot', () {
    final slots = plan(
      now: DateTime(2026, 10, 5, 13, 30),
      lastDrinkAt: DateTime(2026, 10, 5, 9, 15),
      daysAhead: 1,
    );

    expect(slots.first.at, DateTime(2026, 10, 5, 14, 15));
  });

  test('goal reached: skips the rest of today and resumes tomorrow', () {
    final slots = plan(
      now: DateTime(2026, 10, 5, 15, 0),
      goalReached: true,
      daysAhead: 2,
    );

    expect(slots.first.at, DateTime(2026, 10, 6, 9, 0));
    expect(slots.every((s) => !s.isCurrentDay), isTrue);
  });

  test("yesterday's drink does not anchor today's reminders", () {
    final slots = plan(
      now: DateTime(2026, 10, 6, 7, 0),
      lastDrinkAt: DateTime(2026, 10, 5, 21, 30),
      daysAhead: 1,
    );

    expect(slots.first.at, DateTime(2026, 10, 6, 9, 0));
  });

  test('after sleep time: next reminders are tomorrow', () {
    final slots = plan(now: DateTime(2026, 10, 5, 23, 0), daysAhead: 2);

    expect(slots.first.at, DateTime(2026, 10, 6, 9, 0));
  });

  test('sleep after midnight keeps the current overnight window', () {
    final slots = plan(
      now: DateTime(2026, 10, 6, 0, 10),
      wake: '10:00',
      sleep: '01:30',
      interval: 30,
      daysAhead: 1,
    );

    expect(slots.first.at, DateTime(2026, 10, 6, 0, 30));
    expect(slots[1].at, DateTime(2026, 10, 6, 1, 0));
    expect(slots[2].at, DateTime(2026, 10, 6, 10, 30));
  });

  test('never exceeds maxCount', () {
    final slots = plan(
      now: DateTime(2026, 10, 5, 6, 0),
      interval: 30,
      daysAhead: 5,
      maxCount: 60,
    );

    expect(slots.length, 60);
  });

  test('all reminders are at least one minute in the future', () {
    final now = DateTime(2026, 10, 5, 8, 59, 30);
    final slots = plan(now: now, daysAhead: 1);

    expect(slots.first.at.isAfter(now.add(const Duration(minutes: 1))), isTrue);
  });
}
