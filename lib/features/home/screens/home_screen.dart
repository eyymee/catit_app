import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/grocery_provider.dart';
import '../../../providers/routine_provider.dart';
import '../../../models/upcoming_task.dart';
import '../../../providers/upcoming_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/responsive_layout.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedRoutines = ref.watch(completedTodayCountProvider);
    final totalRoutines = ref.watch(totalRoutineCountProvider);
    final totalGroceries = ref.watch(totalGroceryCountProvider);
    final purchasedGroceries = ref.watch(purchasedCountProvider);
    final upcomingTasks = ref.watch(upcomingProvider);
    final pendingUpcoming = upcomingTasks.where((t) => !t.isCompleted).length;

    final progress = totalRoutines == 0
        ? 0.0
        : completedRoutines / totalRoutines;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const AppTopBar(backgroundColor: AppColors.cream),
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
              // Greeting
              Text(
                _greeting(),
                style: AppTextStyles.labelMd(color: AppColors.primaryContainer),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Circular progress
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = (constraints.maxWidth * 0.65).clamp(180.0, 300.0);
                  return Center(
                    child: _CircularProgressWidget(
                      size: size,
                      progress: progress,
                      completed: completedRoutines,
                      total: totalRoutines,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              if (LayoutBreakpoints.isTabletOrWider(context))
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: 'Groceries',
                            actionLabel: 'View all',
                            onAction: () => context.go('/groceries'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _GroceriesSummaryCard(
                            purchased: purchasedGroceries,
                            total: totalGroceries,
                            onTap: () => context.go('/groceries'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: 'Upcoming reminders',
                            actionLabel: 'View all',
                            onAction: () => context.go('/upcoming'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (pendingUpcoming == 0)
                            const _EmptyReminders()
                          else
                            _ReminderList(
                              tasks: upcomingTasks.where((t) => !t.isCompleted).take(3).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                // Groceries summary
                _SectionHeader(
                  title: 'Groceries',
                  actionLabel: 'View all',
                  onAction: () => context.go('/groceries'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _GroceriesSummaryCard(
                  purchased: purchasedGroceries,
                  total: totalGroceries,
                  onTap: () => context.go('/groceries'),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Upcoming reminders
                _SectionHeader(
                  title: 'Upcoming reminders',
                  actionLabel: 'View all',
                  onAction: () => context.go('/upcoming'),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (pendingUpcoming == 0)
                  const _EmptyReminders()
                else
                  _ReminderList(
                    tasks: upcomingTasks.where((t) => !t.isCompleted).take(3).toList(),
                  ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    final salutation = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return '$salutation, Amira';
  }
}

// ── Circular progress ─────────────────────────────────────────

class _CircularProgressWidget extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;
  final double size;

  const _CircularProgressWidget({
    required this.progress,
    required this.completed,
    required this.total,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.headlineLg(color: AppColors.primary),
              ),
              Text(
                'Daily tasks',
                style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
              ),
              if (total > 0)
                Text(
                  '$completed of $total',
                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 12.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.primary.withAlpha(25)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    // Progress arc
    const startAngle = -3.14159 / 2; // -90 degrees
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = AppColors.primaryContainer
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Section header ────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: AppTextStyles.headlineMd()),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: AppTextStyles.labelSm(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ── Groceries summary card ─────────────────────────────────────

class _GroceriesSummaryCard extends StatelessWidget {
  final int purchased;
  final int total;
  final VoidCallback onTap;

  const _GroceriesSummaryCard({
    required this.purchased,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withAlpha(13),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_cart_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                total == 0
                    ? 'No items yet'
                    : '$purchased out of $total items',
                style: AppTextStyles.labelMd(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reminder list ──────────────────────────────────────────────

class _ReminderList extends StatelessWidget {
  final List<UpcomingTask> tasks;
  const _ReminderList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < tasks.length; i++) ...[
          _ReminderCard(task: tasks[i]),
          if (i < tasks.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final UpcomingTask task;

  const _ReminderCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (task.time != null) task.time!,
      _formatDue(task.dueDate),
    ].join(' • ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTextStyles.labelMd()),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff > 1) return 'In $diff days';
    return DateFormat('MMM d').format(date);
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.notifications_none_rounded,
                size: 48, color: AppColors.outline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No upcoming reminders',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
