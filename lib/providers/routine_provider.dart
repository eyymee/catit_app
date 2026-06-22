import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine_task.dart';

const _boxName = 'routines';

class RoutineNotifier extends StateNotifier<List<RoutineTask>> {
  RoutineNotifier() : super([]) {
    _load();
  }

  late final Box<String> _box;

  Future<void> _load() async {
    _box = await Hive.openBox<String>(_boxName);
    if (_box.isEmpty) {
      state = _defaultTasks();
      _save();
    } else {
      state = _box.values.map(RoutineTask.decode).toList();
    }
  }

  List<RoutineTask> _defaultTasks() => [
        RoutineTask(
          title: 'Feed Cat',
          subtitle: 'Morning',
          frequency: RoutineFrequency.daily,
        ),
        RoutineTask(
          title: 'Water Plants',
          subtitle: 'Morning',
          frequency: RoutineFrequency.mwf,
        ),
        RoutineTask(
          title: 'Wash Dishes',
          subtitle: 'Post-meal',
          frequency: RoutineFrequency.daily,
        ),
      ];

  void _save() {
    _box.clear();
    for (final task in state) {
      _box.put(task.id, task.encode());
    }
  }

  void addTask(RoutineTask task) {
    state = [...state, task];
    _save();
  }

  void toggleComplete(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(
            isCompletedToday: !task.isCompletedToday,
            lastCompletedAt:
                !task.isCompletedToday ? DateTime.now() : task.lastCompletedAt,
          )
        else
          task,
    ];
    _save();
  }

  void updateTask(RoutineTask updated) {
    state = [
      for (final task in state) if (task.id == updated.id) updated else task,
    ];
    _save();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
    _save();
  }

  void resetAll() {
    state = [for (final task in state) task.copyWith(isCompletedToday: false)];
    _save();
  }
}

final routineProvider =
    StateNotifierProvider<RoutineNotifier, List<RoutineTask>>(
  (_) => RoutineNotifier(),
);

final completedTodayCountProvider = Provider<int>((ref) {
  return ref.watch(routineProvider).where((t) => t.isCompletedToday).length;
});

final totalRoutineCountProvider = Provider<int>((ref) {
  return ref.watch(routineProvider).length;
});
