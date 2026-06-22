import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'responsive_layout.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Color? backgroundColor;

  const AppTopBar({super.key, this.actions, this.backgroundColor});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isWide = LayoutBreakpoints.isTabletOrWider(context);
    return Container(
      color: backgroundColor ?? AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: LayoutBreakpoints.hPadding(context),
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Text(
              'catit',
              style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
            ),
            const Spacer(),
            if (actions != null) ...actions!,
            Text(
              'Catit down. Get it done.',
              style: TextStyle(
                fontSize: isWide ? 12.0 : 11.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
