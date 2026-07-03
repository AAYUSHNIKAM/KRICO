import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.width,
  });

  final List<Widget> children;
  final Widget? header;
  final Widget? footer;
  final double? width;

  static void open(BuildContext context, Widget drawer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlay,
      builder: (_) => drawer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      width: width ?? MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(left: 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.xl3),
          bottomRight: Radius.circular(AppRadius.xl3),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (header != null)
              Container(
                padding: const EdgeInsets.all(SpacingScale.s16),
                child: header,
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: SpacingScale.s8),
                children: children,
              ),
            ),
            if (footer != null)
              Container(
                padding: EdgeInsets.fromLTRB(
                  SpacingScale.s16,
                  SpacingScale.s12,
                  SpacingScale.s16,
                  bottomInset + SpacingScale.s12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                      width: 0.5,
                    ),
                  ),
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}
