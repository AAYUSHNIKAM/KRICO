import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.showBack = false,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title != null || showBack || leading != null || actions != null
          ? AppBar(
              title: title != null ? Text(title!) : null,
              leading: leading ??
                  (showBack
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      : null),
              actions: actions,
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.title,
    this.actions,
    this.showBack = false,
    this.bottomNavigationBar,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final String? title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1200;

    Widget body;
    if (isMobile) {
      body = mobile;
    } else if (isTablet && tablet != null) {
      body = tablet!;
    } else if (desktop != null) {
      body = desktop!;
    } else {
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: mobile,
        ),
      );
    }

    return AppScaffold(
      title: title,
      actions: actions,
      showBack: showBack,
      bottomNavigationBar: bottomNavigationBar,
      body: body,
    );
  }
}
