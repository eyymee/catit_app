import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/grocery_item.dart';
import '../../../providers/grocery_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/responsive_layout.dart';

class GroceriesScreen extends ConsumerStatefulWidget {
  const GroceriesScreen({super.key});

  @override
  ConsumerState<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends ConsumerState<GroceriesScreen> {
  final _addCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _addCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    ref.read(groceryProvider.notifier).addItem(text);
    _addCtrl.clear();
    _focusNode.requestFocus();
  }

  Future<void> _confirmCompleteList() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Complete list', style: AppTextStyles.headlineMd()),
        content: Text(
          'Mark all items as done and clear the list?',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      ref.read(groceryProvider.notifier).completeList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(groceryProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      resizeToAvoidBottomInset: false,
      appBar: const AppTopBar(backgroundColor: AppColors.cream),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header + input
          ResponsiveLayout(
            padding: EdgeInsets.fromLTRB(
              LayoutBreakpoints.hPadding(context),
              AppSpacing.md,
              LayoutBreakpoints.hPadding(context),
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Groceries', style: AppTextStyles.headlineLgMobile()),
                    GestureDetector(
                      onTap: () =>
                          ref.read(groceryProvider.notifier).clearAll(),
                      child: Text(
                        'Clear all',
                        style:
                            AppTextStyles.labelSm(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _AddItemField(
                  controller: _addCtrl,
                  focusNode: _focusNode,
                  onSubmit: _addItem,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),

          // List or empty state
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ResponsiveLayout(
                  padding: EdgeInsets.symmetric(
                      horizontal: LayoutBreakpoints.hPadding(context)),
                  child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: items.isEmpty
                      ? const Center(child: _EmptyState())
                      : _GroceryList(
                          items: items,
                          onToggle: (id) => ref
                              .read(groceryProvider.notifier)
                              .toggleItem(id),
                          onDelete: (id) => ref
                              .read(groceryProvider.notifier)
                              .deleteItem(id),
                        ),
                  ),
                ),
              ),
            ),
          ),

          if (items.isNotEmpty)
            ResponsiveLayout(
              padding: EdgeInsets.fromLTRB(
                LayoutBreakpoints.hPadding(context),
                AppSpacing.sm,
                LayoutBreakpoints.hPadding(context),
                AppSpacing.xl,
              ),
              child: _CompleteButton(onTap: _confirmCompleteList),
            ),
        ],
      ),
    );
  }
}

// ── Add item field ─────────────────────────────────────────────

class _AddItemField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  const _AddItemField({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  @override
  State<_AddItemField> createState() => _AddItemFieldState();
}

class _AddItemFieldState extends State<_AddItemField> {
  bool _focused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onFocus() => setState(() => _focused = widget.focusNode.hasFocus);
  void _onText() => setState(() => _hasText = widget.controller.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? AppColors.primaryContainer
              : AppColors.outlineVariant.withAlpha(80),
          width: _focused ? 2 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primaryContainer.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMd(),
              decoration: InputDecoration(
                hintText: 'Add milk, eggs, or more...',
                hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
                filled: false,
              ),
              onSubmitted: (_) => widget.onSubmit(),
              textInputAction: TextInputAction.done,
            ),
          ),
          AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: GestureDetector(
                onTap: widget.onSubmit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grocery list ───────────────────────────────────────────────

class _GroceryList extends StatelessWidget {
  final List<GroceryItem> items;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;

  const _GroceryList({
    required this.items,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _GroceryItemTile(
              item: items[i],
              onToggle: () => onToggle(items[i].id),
              onDelete: () => onDelete(items[i].id),
            ),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
                color: AppColors.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _GroceryItemTile extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GroceryItemTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isPurchased
                    ? AppColors.secondary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: item.isPurchased
                      ? AppColors.secondary
                      : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: item.isPurchased
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: item.isPurchased
                  ? AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                      .copyWith(
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.onSurfaceVariant,
                    )
                  : AppTextStyles.bodyMd(),
              child: Text(item.name),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.outlineVariant,
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ── Complete button ────────────────────────────────────────────

class _CompleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CompleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Complete list',
              style: AppTextStyles.labelMd(color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.done_all_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shopping_basket_rounded,
              color: AppColors.outline, size: 36),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Your basket is empty', style: AppTextStyles.headlineMd()),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Add items to start your shopping journey',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
