import 'package:flutter/material.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/app_color_scheme.dart';
import '../../design_system/typography/text_styles.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.selected,
      secondary: AppColors.cyan,
      secondaryContainer: AppColors.cyan.withValues(alpha: 0.15),
      tertiary: AppColors.volt,
      surface: AppColors.background,
      surfaceContainerHighest: AppColors.surfaceElevated,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.dangerLight,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [AppColorScheme.dark],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTextStyles.heading1.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        headlineLarge: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTextStyles.title1.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTextStyles.title2.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTextStyles.title1.copyWith(color: AppColors.textPrimary),
        titleMedium: AppTextStyles.title2.copyWith(color: AppColors.textPrimary),
        titleSmall: AppTextStyles.title3.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        bodySmall: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        labelMedium: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
        labelSmall: AppTextStyles.captionXs.copyWith(color: AppColors.textTertiary),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.title1.copyWith(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColors.border, width: 1.0),
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTextStyles.button,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.volt, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dangerLight),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: AppColors.volt,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceSecondary,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surfaceElevated,
        indicatorColor: AppColors.selected,
        labelType: NavigationRailLabelType.all,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: AppTextStyles.labelSm.copyWith(color: AppColors.textPrimary),
        backgroundColor: AppColors.surfaceElevated,
        side: const BorderSide(color: AppColors.border),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.volt;
          return AppColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.volt.withValues(alpha: 0.3);
          return AppColors.border;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.volt,
        foregroundColor: AppColors.textInverse,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.voltDark,
      primaryContainer: AppColors.lightSelected,
      secondary: AppColors.cyanDark,
      secondaryContainer: AppColors.cyanLight.withValues(alpha: 0.2),
      tertiary: AppColors.voltDark,
      surface: AppColors.lightBackground,
      surfaceContainerHighest: AppColors.lightCard,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      error: AppColors.danger,
      outline: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [AppColorScheme.light],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: AppColors.lightTextPrimary),
        displayMedium: AppTextStyles.heading1.copyWith(color: AppColors.lightTextPrimary),
        displaySmall: AppTextStyles.heading2.copyWith(color: AppColors.lightTextPrimary),
        headlineLarge: AppTextStyles.heading3.copyWith(color: AppColors.lightTextPrimary),
        headlineMedium: AppTextStyles.title1.copyWith(color: AppColors.lightTextPrimary),
        headlineSmall: AppTextStyles.title2.copyWith(color: AppColors.lightTextPrimary),
        titleLarge: AppTextStyles.title1.copyWith(color: AppColors.lightTextPrimary),
        titleMedium: AppTextStyles.title2.copyWith(color: AppColors.lightTextPrimary),
        titleSmall: AppTextStyles.title3.copyWith(color: AppColors.lightTextPrimary),
        bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: AppColors.lightTextPrimary),
        bodySmall: AppTextStyles.bodySm.copyWith(color: AppColors.lightTextSecondary),
        labelLarge: AppTextStyles.label.copyWith(color: AppColors.lightTextPrimary),
        labelMedium: AppTextStyles.labelSm.copyWith(color: AppColors.lightTextSecondary),
        labelSmall: AppTextStyles.captionXs.copyWith(color: AppColors.lightTextTertiary),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        titleTextStyle: AppTextStyles.title1.copyWith(color: AppColors.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
        color: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.lightTextPrimary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
          foregroundColor: AppColors.lightTextPrimary,
          textStyle: AppTextStyles.button,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.lightTextPrimary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: AppColors.lightTextPrimary,
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightTextPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.lightTextSecondary),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.lightTextTertiary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: AppColors.lightTextPrimary,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.lightCard,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightCard,
        indicatorColor: AppColors.lightSelected,
        labelType: NavigationRailLabelType.all,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: AppTextStyles.labelSm.copyWith(color: AppColors.lightTextPrimary),
        backgroundColor: AppColors.lightCard,
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.lightTextPrimary;
          return AppColors.lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.lightTextPrimary.withValues(alpha: 0.3);
          return AppColors.lightBorder;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
