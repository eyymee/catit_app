import 'dart:convert';
import 'package:uuid/uuid.dart';

enum RoutineFrequency { daily, weekdays, mwf, weekly, custom }

extension RoutineFrequencyX on RoutineFrequency {
  String get label => switch (this) {
        RoutineFrequency.daily => 'Daily',
        RoutineFrequency.weekdays => 'Weekdays',
        RoutineFrequency.mwf => 'Mon, Wed, Fri',
        RoutineFrequency.weekly => 'Weekly',
        RoutineFrequency.custom => 'Custom',
      };
}

class RoutineTask {
  final String id;
  final String title;
  final String subtitle;
  final RoutineFrequency frequency;
  final bool isCompletedToday;
  final DateTime? lastCompletedAt;
  final int? scheduledHour;
  final int? scheduledMinute;

  RoutineTask({
    String? id,
    required this.title,
    this.subtitle = '',
    this.frequency = RoutineFrequency.daily,
    this.isCompletedToday = false,
    this.lastCompletedAt,
    this.scheduledHour,
    this.scheduledMinute,
  }) : id = id ?? const Uuid().v4();

  bool get hasTime => scheduledHour != null && scheduledMinute != null;

  String get formattedTime {
    if (!hasTime) return '';
    final h = scheduledHour!;
    final m = scheduledMinute!;
    final period = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final min = m.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  RoutineTask copyWith({
    String? title,
    String? subtitle,
    RoutineFrequency? frequency,
    bool? isCompletedToday,
    DateTime? lastCompletedAt,
    int? scheduledHour,
    int? scheduledMinute,
    bool clearTime = false,
  }) =>
      RoutineTask(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        frequency: frequency ?? this.frequency,
        isCompletedToday: isCompletedToday ?? this.isCompletedToday,
        lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
        scheduledHour: clearTime ? null : (scheduledHour ?? this.scheduledHour),
        scheduledMinute: clearTime ? null : (scheduledMinute ?? this.scheduledMinute),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'frequency': frequency.name,
        'isCompletedToday': isCompletedToday,
        'lastCompletedAt': lastCompletedAt?.toIso8601String(),
        'scheduledHour': scheduledHour,
        'scheduledMinute': scheduledMinute,
      };

  factory RoutineTask.fromJson(Map<String, dynamic> j) => RoutineTask(
        id: j['id'] as String,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String? ?? '',
        frequency: RoutineFrequency.values.firstWhere(
          (f) => f.name == j['frequency'],
          orElse: () => RoutineFrequency.daily,
        ),
        isCompletedToday: j['isCompletedToday'] as bool? ?? false,
        lastCompletedAt: j['lastCompletedAt'] != null
            ? DateTime.parse(j['lastCompletedAt'] as String)
            : null,
        scheduledHour: j['scheduledHour'] as int?,
        scheduledMinute: j['scheduledMinute'] as int?,
      );

  String encode() => jsonEncode(toJson());
  static RoutineTask decode(String s) =>
      RoutineTask.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
