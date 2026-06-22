import 'dart:convert';
import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };
}

class UpcomingTask {
  final String id;
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final String? time;
  final String? location;
  final TaskPriority priority;
  final bool isCompleted;

  UpcomingTask({
    String? id,
    required this.title,
    this.subtitle = '',
    required this.dueDate,
    this.time,
    this.location,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  UpcomingTask copyWith({
    String? title,
    String? subtitle,
    DateTime? dueDate,
    String? time,
    String? location,
    TaskPriority? priority,
    bool? isCompleted,
  }) =>
      UpcomingTask(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        dueDate: dueDate ?? this.dueDate,
        time: time ?? this.time,
        location: location ?? this.location,
        priority: priority ?? this.priority,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'dueDate': dueDate.toIso8601String(),
        'time': time,
        'location': location,
        'priority': priority.name,
        'isCompleted': isCompleted,
      };

  factory UpcomingTask.fromJson(Map<String, dynamic> j) => UpcomingTask(
        id: j['id'] as String,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String? ?? '',
        dueDate: DateTime.parse(j['dueDate'] as String),
        time: j['time'] as String?,
        location: j['location'] as String?,
        priority: TaskPriority.values.firstWhere(
          (p) => p.name == j['priority'],
          orElse: () => TaskPriority.medium,
        ),
        isCompleted: j['isCompleted'] as bool? ?? false,
      );

  String encode() => jsonEncode(toJson());
  static UpcomingTask decode(String s) =>
      UpcomingTask.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
