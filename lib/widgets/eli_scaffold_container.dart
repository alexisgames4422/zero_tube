import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EliScaffoldContainer extends StatelessWidget {
  const EliScaffoldContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWide = maxWidth > 720;
        final constrainedWidth = isWide ? 640.0 : double.infinity;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constrainedWidth),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: padding,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(isWide ? 0.6 : 0.0),
                borderRadius: BorderRadius.circular(isWide ? 24 : 0),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
