import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PremiumActionButton extends StatelessWidget {
  const PremiumActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.secondary = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final foreground = secondary ? AppColors.primary : Colors.white;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: secondary
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
          color: secondary ? AppColors.surface : null,
          border: secondary ? Border.all(color: AppColors.border) : null,
          boxShadow: [
            BoxShadow(
              color: (secondary ? AppColors.primary : AppColors.primaryDark)
                  .withValues(alpha: secondary ? 0.08 : 0.22),
              blurRadius: secondary ? 14 : 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 54,
              child: Center(
                child: loading
                    ? SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: foreground,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 20, color: foreground),
                            const SizedBox(width: 9),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
