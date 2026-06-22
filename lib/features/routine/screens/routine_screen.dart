import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/routine_task.dart';
import '../../../providers/routine_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/time_picker_sheet.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  int _tabIndex = 0;

  Future<void> _showAddDialog([RoutineTask? existing]) async {
    final task = await showDialog<RoutineTask>(
      context: context,
      builder: (_) => _RoutineDialog(task: existing),
    );
    if (task == null || !mounted) return;
    if (existing == null) {
      ref.read(routineProvider.notifier).addTask(task);
    } else {
      ref.read(routineProvider.notifier).updateTask(task);
    }
  }

  Future<void> _confirmDelete(RoutineTask task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Routine', style: AppTextStyles.headlineMd()),
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
      ref.read(routineProvider.notifier).deleteTask(task.id);
    }
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Routines', style: AppTextStyles.headlineMd()),
        content: Text(
          'Mark all routines as incomplete for today?',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true && mounted) {
      ref.read(routineProvider.notifier).resetAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(routineProvider);
    final completed = ref.watch(completedTodayCountProvider);
    final total = ref.watch(totalRoutineCountProvider);
    final pending = tasks.where((t) => !t.isCompletedToday).toList();
    final done = tasks.where((t) => t.isCompletedToday).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppTopBar(
        backgroundColor: AppColors.cream,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ResponsiveLayout(
          padding: EdgeInsets.symmetric(
            horizontal: LayoutBreakpoints.hPadding(context),
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress card
              _ProgressCard(
                completed: completed,
                total: total,
                onReset: tasks.isNotEmpty ? _confirmReset : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tabs
              _RoutineTabs(
                selectedIndex: _tabIndex,
                onTabChanged: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: AppSpacing.md),

              // Task list
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _tabIndex == 0
                    ? _TaskList(
                        key: const ValueKey('pending'),
                        tasks: pending,
                        onToggle: (id) =>
                            ref.read(routineProvider.notifier).toggleComplete(id),
                        onEdit: (task) => _showAddDialog(task),
                        onDelete: _confirmDelete,
                        isEmpty: pending.isEmpty,
                        emptyMessage: 'No pending routines',
                        emptyIcon: Icons.check_circle_outline_rounded,
                      )
                    : _TaskList(
                        key: const ValueKey('completed'),
                        tasks: done,
                        onToggle: (id) =>
                            ref.read(routineProvider.notifier).toggleComplete(id),
                        onEdit: (task) => _showAddDialog(task),
                        onDelete: _confirmDelete,
                        isEmpty: done.isEmpty,
                        emptyMessage: 'Nothing completed yet today',
                        emptyIcon: Icons.hourglass_empty_rounded,
                      ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showAddDialog(),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add_rounded, size: 20),
      ),
    );
  }
}

// ── Progress card ──────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final VoidCallback? onReset;

  const _ProgressCard({
    required this.completed,
    required this.total,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.centerRight,
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily progress', style: AppTextStyles.headlineMd()),
                    Text(
                      '$completed of $total tasks completed',
                      style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Reset all',
                child: GestureDetector(
                  onTap: onReset,
                  child: Icon(
                    Icons.restart_alt_rounded,
                    size: 18,
                    color: onReset != null
                        ? AppColors.primaryContainer
                        : AppColors.outline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryContainer),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tabs ───────────────────────────────────────────────────────

class _RoutineTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _RoutineTabs({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Pending',
            isSelected: selectedIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _TabItem(
            label: 'Completed',
            isSelected: selectedIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMd(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Task list ──────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  final List<RoutineTask> tasks;
  final ValueChanged<String> onToggle;
  final ValueChanged<RoutineTask> onEdit;
  final ValueChanged<RoutineTask> onDelete;
  final bool isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;

  const _TaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.isEmpty,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Column(
            children: [
              Icon(emptyIcon, size: 48, color: AppColors.outline),
              const SizedBox(height: AppSpacing.sm),
              Text(emptyMessage,
                  style:
                      AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final task in tasks) ...[
          _RoutineTaskCard(
            task: task,
            onToggle: () => onToggle(task.id),
            onEdit: () => onEdit(task),
            onDelete: () => onDelete(task),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _RoutineTaskCard extends StatelessWidget {
  final RoutineTask task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoutineTaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.isCompletedToday;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: done
            ? AppColors.secondaryContainer.withAlpha(30)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? AppColors.secondary.withAlpha(80)
              : AppColors.outlineVariant.withAlpha(80),
        ),
        boxShadow: done
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? AppColors.secondary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done
                      ? AppColors.secondary
                      : AppColors.primaryContainer,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: done
                      ? AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                          .copyWith(decoration: TextDecoration.lineThrough)
                      : AppTextStyles.labelMd(),
                  child: Text(task.title),
                ),
                if (task.subtitle.isNotEmpty || task.hasTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        if (task.hasTime) task.formattedTime,
                        if (task.subtitle.isNotEmpty) task.subtitle,
                      ].join(' • '),
                      style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                size: 18, color: AppColors.onSurfaceVariant),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  const Icon(Icons.edit_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text('Edit', style: AppTextStyles.bodyMd()),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text('Delete',
                      style: AppTextStyles.bodyMd(color: AppColors.error)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add / Edit dialog ──────────────────────────────────────────

class _RoutineDialog extends StatefulWidget {
  final RoutineTask? task;
  const _RoutineDialog({this.task});

  @override
  State<_RoutineDialog> createState() => _RoutineDialogState();
}

class _RoutineDialogState extends State<_RoutineDialog> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  TimeOfDay? _time;
  bool _showTitleError = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _subtitleCtrl.text = widget.task!.subtitle;
      if (widget.task!.hasTime) {
        _time = TimeOfDay(
          hour: widget.task!.scheduledHour!,
          minute: widget.task!.scheduledMinute!,
        );
      }
    }
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
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _showTitleError = true);
      return;
    }
    Navigator.pop(
      context,
      RoutineTask(
        id: widget.task?.id,
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim(),
        frequency: RoutineFrequency.daily,
        scheduledHour: _time?.hour,
        scheduledMinute: _time?.minute,
        isCompletedToday: widget.task?.isCompletedToday ?? false,
        lastCompletedAt: widget.task?.lastCompletedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.task != null ? 'Edit routine' : 'Add routine',
        style: AppTextStyles.headlineMd(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task name', style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                enabledBorder: _showTitleError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.error, width: 1),
                      )
                    : null,
              ),
              onSubmitted: (_) => _submit(),
              onChanged: (v) {
                if (_showTitleError && v.trim().isNotEmpty) {
                  setState(() => _showTitleError = false);
                }
              },
            ),
            if (_showTitleError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Required',
                  style: AppTextStyles.labelSm(color: AppColors.error),
                ),
              ),
            const SizedBox(height: 12),
            Text('Description', style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextField(
              controller: _subtitleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 12),
            Text('Time', style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
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
                    Icon(Icons.access_time_rounded, size: 18, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _time != null ? _time!.format(context) : 'Set time',
                        style: AppTextStyles.bodyMd(
                          color: _time != null ? AppColors.onSurface : AppColors.outline,
                        ),
                      ),
                    ),
                    if (_time != null)
                      GestureDetector(
                        onTap: () => setState(() => _time = null),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.outline),
                      ),
                  ],
                ),
              ),
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
          child: Text(widget.task != null ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
