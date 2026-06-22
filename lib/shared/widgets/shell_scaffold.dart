import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const ShellScaffold({
    super.key,
    required this.child,
    required this.state,
  });

  int get _selectedIndex => locationToIndex(state.uri.toString());

  void _onNav(BuildContext context, int index) =>
      context.go(indexToLocation(index));

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 600) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Row(
          children: [
            _NavRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => _onNav(context, i),
            ),
            const VerticalDivider(width: 1, color: AppColors.outlineVariant),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: child,
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => _onNav(context, i),
      ),
    );
  }
}

// ── Bottom nav (mobile) ──────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _BottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _items = [
    (icon: Icons.home_outlined, filled: Icons.home_rounded, label: 'Home'),
    (icon: Icons.shopping_cart_outlined, filled: Icons.shopping_cart_rounded, label: 'Groceries'),
    (icon: Icons.sync_rounded, filled: Icons.sync_rounded, label: 'Routines'),
    (icon: Icons.calendar_today_outlined, filled: Icons.calendar_today_rounded, label: 'Upcoming'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _items[i].icon,
                    filledIcon: _items[i].filled,
                    label: _items[i].label,
                    isSelected: selectedIndex == i,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withAlpha(26)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSm(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Navigation rail (tablet/desktop) ───────────────────────────

class _NavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _NavRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _destinations = [
    (icon: Icons.home_outlined, filled: Icons.home_rounded, label: 'Home'),
    (icon: Icons.shopping_cart_outlined, filled: Icons.shopping_cart_rounded, label: 'Groceries'),
    (icon: Icons.sync_rounded, filled: Icons.sync_rounded, label: 'Routines'),
    (icon: Icons.calendar_today_outlined, filled: Icons.calendar_today_rounded, label: 'Upcoming'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: AppColors.surfaceContainerLowest,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
      selectedLabelTextStyle: AppTextStyles.labelSm(color: AppColors.primary)
          .copyWith(fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
      indicatorColor: AppColors.primary,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.note_alt_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Catit',
              style: AppTextStyles.labelSm(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      destinations: _destinations
          .map((d) => NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.filled),
                label: Text(d.label),
              ))
          .toList(),
    );
  }
}
