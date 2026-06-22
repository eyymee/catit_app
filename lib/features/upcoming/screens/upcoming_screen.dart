import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/upcoming_task.dart';
import '../../../providers/upcoming_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/time_picker_sheet.dart';

class UpcomingScreen extends ConsumerStatefulWidget {
  const UpcomingScreen({super.key});

  @override
  ConsumerState<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends ConsumerState<UpcomingScreen> {
  DateTime _selectedDay = DateTime.now();

  Future<void> _showAddDialog() async {
    final task = await showDialog<UpcomingTask>(
      context: context,
      builder: (_) => _AddTaskDialog(initialDate: _selectedDay),
    );
    if (task != null && mounted) {
      ref.read(upcomingProvider.notifier).addTask(task);
    }
  }

  Future<void> _showEditDialog(UpcomingTask existing) async {
    final updated = await showDialog<UpcomingTask>(
      context: context,
      builder: (_) => _AddTaskDialog(initialDate: existing.dueDate, task: existing),
    );
    if (updated != null && mounted) {
      ref.read(upcomingProvider.notifier).updateTask(updated);
    }
  }

  Future<void> _confirmDelete(UpcomingTask task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete event', style: AppTextStyles.headlineMd()),
        content: Text('Remove "${task.title}"?',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      ref.read(upcomingProvider.notifier).deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectioned = ref.watch(sectionedUpcomingProvider);
    final activeSections = TaskSection.values
        .where((s) => sectioned[s]!.isNotEmpty)
        .toList();
    final completed = ref.watch(completedUpcomingProvider);
    final hPad = LayoutBreakpoints.hPadding(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppTopBar(
        backgroundColor: AppColors.cream,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ResponsiveLayout(
              padding: EdgeInsets.fromLTRB(hPad, AppSpacing.md, hPad, AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                    style: AppTextStyles.labelSm(
                      color: AppColors.onSurfaceVariant,
                    ).copyWith(letterSpacing: 1.4),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CalendarStrip(
                    selectedDay: _selectedDay,
                    onDaySelected: (d) => setState(() => _selectedDay = d),
                  ),
                ],
              ),
            ),
          ),

          if (activeSections.isEmpty && completed.isEmpty)
            SliverFillRemaining(child: _EmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final section = activeSections[i];
                  return ResponsiveLayout(
                    padding: EdgeInsets.fromLTRB(hPad, AppSpacing.md, hPad, 0),
                    child: _SectionGroup(
                      section: section,
                      tasks: sectioned[section]!,
                      onToggle: (id) =>
                          ref.read(upcomingProvider.notifier).toggleComplete(id),
                      onEdit: _showEditDialog,
                      onDelete: _confirmDelete,
                    ),
                  );
                },
                childCount: activeSections.length,
              ),
            ),

          if (completed.isNotEmpty)
            SliverToBoxAdapter(
              child: ResponsiveLayout(
                padding: EdgeInsets.fromLTRB(hPad, AppSpacing.md, hPad, 0),
                child: _CompletedSection(
                  tasks: completed,
                  onToggle: (id) =>
                      ref.read(upcomingProvider.notifier).toggleComplete(id),
                  onEdit: _showEditDialog,
                  onDelete: _confirmDelete,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add_rounded, size: 20),
      ),
    );
  }
}

// ── Calendar strip ─────────────────────────────────────────────

class _CalendarStrip extends StatelessWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarStrip({
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final dayCount = LayoutBreakpoints.isTabletOrWider(context) ? 7 : 5;
    final days = List.generate(dayCount, (i) => today.add(Duration(days: i - dayCount ~/ 2)));
    const gap = 8.0;
    final circleSize = LayoutBreakpoints.isTabletOrWider(context) ? 52.0 : 42.0;
    final stripHeight = circleSize + 32.0;

    return SizedBox(
      height: stripHeight,
      child: Row(
        children: [
          for (int i = 0; i < dayCount; i++) ...[
            if (i > 0) const SizedBox(width: gap),
            Expanded(
              child: GestureDetector(
                onTap: () => onDaySelected(days[i]),
                child: _DayCard(
                  day: days[i],
                  today: today,
                  circleSize: circleSize,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  final DateTime today;
  final double circleSize;

  const _DayCard({
    required this.day,
    required this.today,
    required this.circleSize,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = day == today;

    const orange = Color(0xFFE8692A);
    const brown = Color(0xFF3D2C1E);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat('EEE').format(day),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? orange : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? orange : Colors.transparent,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: orange.withAlpha(100),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : brown,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section group ───────────────────────────────────────────────

class _SectionGroup extends StatelessWidget {
  final TaskSection section;
  final List<UpcomingTask> tasks;
  final ValueChanged<String> onToggle;
  final ValueChanged<UpcomingTask> onEdit;
  final ValueChanged<UpcomingTask> onDelete;

  const _SectionGroup({
    required this.section,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  static Color _sectionColor(TaskSection s) => switch (s) {
        TaskSection.today => const Color(0xFFE8692A),
        TaskSection.thisWeek => const Color(0xFF2E7D52),
        TaskSection.thisMonth => const Color(0xFF8B6914),
        TaskSection.future => const Color(0xFF546E7A),
      };

  static IconData _sectionIcon(TaskSection s) => switch (s) {
        TaskSection.today => Icons.wb_sunny_rounded,
        TaskSection.thisWeek => Icons.date_range_rounded,
        TaskSection.thisMonth => Icons.calendar_month_rounded,
        TaskSection.future => Icons.rocket_launch_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = _sectionColor(section);
    final showDate = section != TaskSection.today;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Icon(_sectionIcon(section), size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              section.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: color.withAlpha(70)),
              ),
              child: Text(
                '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Task cards
        for (int i = 0; i < tasks.length; i++) ...[
          _TaskCard(
            task: tasks[i],
            showDate: showDate,
            onToggle: () => onToggle(tasks[i].id),
            onEdit: () => onEdit(tasks[i]),
            onDelete: () => onDelete(tasks[i]),
          ),
          if (i < tasks.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

// ── Completed section ──────────────────────────────────────────

class _CompletedSection extends StatelessWidget {
  final List<UpcomingTask> tasks;
  final ValueChanged<String> onToggle;
  final ValueChanged<UpcomingTask> onEdit;
  final ValueChanged<UpcomingTask> onDelete;

  const _CompletedSection({
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF9E9E9E);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_outline_rounded,
                size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              'Completed',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: color.withAlpha(70)),
              ),
              child: Text(
                '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TaskCard(
                task: task,
                showDate: true,
                onToggle: () => onToggle(task.id),
                onEdit: () => onEdit(task),
                onDelete: () => onDelete(task),
              ),
            )),
      ],
    );
  }
}

// ── Task card ──────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final UpcomingTask task;
  final bool showDate;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    this.showDate = false,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? AppColors.surfaceContainerLow
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.outlineVariant.withAlpha(50)),
            boxShadow: task.isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? AppColors.secondary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.secondary
                          : AppColors.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: task.isCompleted
                          ? AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                              .copyWith(decoration: TextDecoration.lineThrough)
                          : AppTextStyles.bodyMd()
                              .copyWith(fontWeight: FontWeight.w600),
                      child: Text(task.title),
                    ),
                    if (task.subtitle.isNotEmpty)
                      Text(task.subtitle,
                          style: AppTextStyles.labelSm(
                              color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (showDate)
                          _Chip(
                            icon: Icons.calendar_today_rounded,
                            label: DateFormat('EEE, MMM d').format(task.dueDate),
                            bgColor: AppColors.surfaceContainerLow,
                            textColor: AppColors.onSurfaceVariant,
                          ),
                        if (task.time != null)
                          _Chip(
                            icon: Icons.schedule_rounded,
                            label: task.time!,
                            bgColor: AppColors.tertiaryContainer.withAlpha(80),
                            textColor: AppColors.onTertiaryContainer,
                          ),
                        if (task.priority == TaskPriority.high)
                          const _Chip(
                            icon: Icons.priority_high_rounded,
                            label: 'High',
                            bgColor: AppColors.errorContainer,
                            textColor: AppColors.onErrorContainer,
                          ),
                        if (task.location != null)
                          _Chip(
                            icon: Icons.location_on_rounded,
                            label: task.location!,
                            bgColor: AppColors.secondaryContainer.withAlpha(80),
                            textColor: AppColors.onSecondaryContainer,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 16, color: AppColors.outline),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Edit',
                          style: AppTextStyles.bodyMd(
                              color: AppColors.primary)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Delete',
                          style: AppTextStyles.bodyMd(
                              color: AppColors.error)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Accent bar
        Positioned(
          left: 0,
          top: 10,
          bottom: 10,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: _accentColor(task.priority),
              borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }

  Color _accentColor(TaskPriority p) => switch (p) {
        TaskPriority.high => AppColors.error,
        TaskPriority.medium => AppColors.tertiaryContainer,
        TaskPriority.low => AppColors.secondaryContainer,
      };
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Chip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.labelSm(color: textColor)),
        ],
      ),
    );
  }
}

// ── Add task dialog ────────────────────────────────────────────

class _AddTaskDialog extends StatefulWidget {
  final DateTime initialDate;
  final UpcomingTask? task;
  const _AddTaskDialog({required this.initialDate, this.task});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  late DateTime _dueDate;
  bool _showTitleError = false;
  TimeOfDay? _time;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _dueDate = t?.dueDate ?? widget.initialDate;
    if (t != null) {
      _titleCtrl.text = t.title;
      _subtitleCtrl.text = t.subtitle;
      _locationCtrl.text = t.location ?? '';
      _priority = t.priority;
      _time = _parseTimeString(t.time);
    }
  }

  TimeOfDay? _parseTimeString(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      final parts = s.split(' ');
      final tp = parts[0].split(':');
      int h = int.parse(tp[0]);
      final m = int.parse(tp[1]);
      final pm = parts[1].toUpperCase() == 'PM';
      if (pm && h != 12) h += 12;
      if (!pm && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return null;
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimePickerSheet(initialTime: _time ?? TimeOfDay.now()),
    );
    if (result != null) setState(() => _time = result);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _showTitleError = true);
      return;
    }
    Navigator.pop(
      context,
      UpcomingTask(
        id: widget.task?.id,
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim(),
        dueDate: _dueDate,
        time: _time != null ? _formatTime(_time!) : null,
        location:
            _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        priority: _priority,
        isCompleted: widget.task?.isCompleted ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'Edit event' : 'New event',
        style: AppTextStyles.headlineMd(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title', style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(),
              onChanged: (_) {
                if (_showTitleError) setState(() => _showTitleError = false);
              },
            ),
            if (_showTitleError)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text('Required',
                    style: AppTextStyles.labelSm(color: AppColors.error)),
              ),
            const SizedBox(height: 14),
            Text('Description', style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _subtitleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 14),
            Text('Date', style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18,
                        color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DateFormat('EEE, MMM d, yyyy').format(_dueDate),
                        style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Time', style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 18,
                        color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _time != null ? _formatTime(_time!) : 'Set time',
                        style: AppTextStyles.bodyMd(
                          color: _time != null
                              ? AppColors.onSurface
                              : AppColors.outline,
                        ),
                      ),
                    ),
                    if (_time != null)
                      GestureDetector(
                        onTap: () => setState(() => _time = null),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.outline),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Location', style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(),
            ),
              const SizedBox(height: 16),
              Text('Priority',
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final sel = p == _priority;
                  final isLast = p == TaskPriority.values.last;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primaryFixed
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: sel
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p.label,
                              style: AppTextStyles.labelSm(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

// ── Empty state ────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 64, color: AppColors.outline),
          const SizedBox(height: AppSpacing.md),
          Text('No upcoming tasks',
              style: AppTextStyles.headlineMd(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add a task to get started',
            style: AppTextStyles.bodyMd(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
