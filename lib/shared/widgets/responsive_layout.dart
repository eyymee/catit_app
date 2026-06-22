import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 720,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

class LayoutBreakpoints {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 &&
      MediaQuery.sizeOf(context).width < 1200;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1200;
  static bool isTabletOrWider(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  static double hPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1200) return 48.0;
    if (w >= 600) return 32.0;
    return 20.0;
  }
}
