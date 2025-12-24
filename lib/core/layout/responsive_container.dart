import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool
  fullWidthMobile; // If true, mobile has 0 padding (good for banners)

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.fullWidthMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(context),
          ),
          child: child,
        ),
      ),
    );
  }

  double _getHorizontalPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    // Mobile (< 600)
    if (width < 600) {
      return fullWidthMobile ? 0 : AppSpacing.mobileScreenPadding;
    }
    // Tablet / Desktop
    return AppSpacing.webScreenPadding;
  }
}
