import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/upcoming_task.dart';

const _boxName = 'upcoming';
const _metaBoxName = 'upcoming_meta';
const _lastResetKey = 'last_weekly_reset';

class UpcomingNotifier extends StateNotifier<List<UpcomingTask>> {
  UpcomingNotifier() : super([]) {
    _load();
  }

  late final Box<String> _box;
  late final Box<String> _metaBox;

  Future<void> _load() async {
    _box = await Hive.openBox<String>(_boxName);
    _metaBox = await Hive.openBox<String>(_metaBoxName);
    state = _box.values.map(UpcomingTask.decode).toList();
    _purgeCompletedIfWeeklyReset();
  }

  void _purgeCompletedIfWeeklyReset() {
    final now = DateTime.now();
    final cutoff = _lastPassedSunday2359(now);
    final stored = _metaBox.get(_lastResetKey);
    final lastReset = stored != null ? DateTime.tryParse(stored) : null;
    if (lastReset == null || lastReset.isBefore(cutoff)) {
      state = state.where((t) => !t.isCompleted).toList();
      _metaBox.put(_lastResetKey, cutoff.toIso8601String());
      _save();
    }
  }

  // Returns the most recent Sunday 23:59:00 that has already passed.
  static DateTime _lastPassedSunday2359(DateTime now) {
    final daysSinceSunday = now.weekday % 7; // Mon=1..Sun=7; Sun%7=0
    final thisSunday = DateTime(
        now.year, now.month, now.day - daysSinceSunday, 23, 59, 0);
    return now.isBefore(thisSunday)
        ? thisSunday.subtract(const Duration(days: 7))
        : thisSunday;
  }

  void _save() {
    _box.clear();
    for (final task in state) {
      _box.put(task.id, task.encode());
    }
  }

  void addTask(UpcomingTask task) {
    state = [...state, task];
    _save();
  }

  void toggleComplete(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
    _save();
  }

  void updateTask(UpcomingTask updated) {
    state = [
      for (final task in state)
        if (task.id == updated.id) updated else task,
    ];
    _save();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
    _save();
  }
}

final upcomingProvider =
    StateNotifierProvider<UpcomingNotifier, List<UpcomingTask>>(
  (_) => UpcomingNotifier(),
);

enum TaskSection { today, thisWeek, thisMonth, future }

extension TaskSectionX on TaskSection {
  String get label => switch (this) {
        TaskSection.today => 'Today',
        TaskSection.thisWeek => 'This week',
        TaskSection.thisMonth => 'This month',
        TaskSection.future => 'Future',
      };
}

final sectionedUpcomingProvider =
    Provider<Map<TaskSection, List<UpcomingTask>>>((ref) {
  final tasks = ref.watch(upcomingProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final endOfWeek = today.add(Duration(days: 7 - today.weekday));
  final endOfMonth =
      DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

  final map = <TaskSection, List<UpcomingTask>>{
    for (final s in TaskSection.values) s: [],
  };

  final sorted = tasks.toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  for (final task in sorted) {
    if (task.isCompleted) continue;
    final due =
        DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    if (!due.isAfter(today)) {
      map[TaskSection.today]!.add(task);
    } else if (!due.isAfter(endOfWeek)) {
      map[TaskSection.thisWeek]!.add(task);
    } else if (!due.isAfter(endOfMonth)) {
      map[TaskSection.thisMonth]!.add(task);
    } else {
      map[TaskSection.future]!.add(task);
    }
  }

  return map;
});

final completedUpcomingProvider = Provider<List<UpcomingTask>>((ref) {
  final tasks = ref.watch(upcomingProvider);
  return tasks.where((t) => t.isCompleted).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});
