import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';
import '../../icons/app_icons.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (Color bg, Color fg, IconData icon) = switch (type) {
      ToastType.success => (AppColors.success, Colors.white, AppIcons.checkCircle),
      ToastType.error => (AppColors.danger, Colors.white, AppIcons.error),
      ToastType.warning => (AppColors.warning, Colors.white, AppIcons.warning),
      ToastType.info => (isDark ? AppColors.surfaceElevated : AppColors.lightSurface, 
                         isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                         AppIcons.info),
    };

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        bgColor: bg,
        fgColor: fg,
        icon: icon,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.bgColor,
    required this.fgColor,
    required this.icon,
    required this.onDismiss,
  });

  final String message;
  final Color bgColor;
  final Color fgColor;
  final IconData icon;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: DurationTokens.slower);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingScale.s16,
                vertical: SpacingScale.s12,
              ),
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: AppRadius.brXl2,
                border: Border.all(
                  color: widget.bgColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, size: 20, color: widget.fgColor),
                  SizedBox(width: SpacingScale.s10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.body.copyWith(color: widget.fgColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Icon(
                      AppIcons.close,
                      size: 16,
                      color: widget.fgColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
