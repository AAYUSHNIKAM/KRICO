import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primary.withValues(alpha: 0.15),
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondary.withValues(alpha: 0.15),
      tertiary: AppColors.accent,
      surface: AppColors.surfaceDark,
      surfaceContainerHighest: AppColors.cardDark,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.error,
      outline: AppColors.borderLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.cardDark,
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
          foregroundColor: AppColors.surfaceDark,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardMid,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDim,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceMid,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: AppTextStyles.labelMedium,
        backgroundColor: AppColors.cardDark,
        side: const BorderSide(color: AppColors.borderLight),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.cardMid,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textDim;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary.withValues(alpha: 0.3);
          return AppColors.borderLight;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primaryDark,
      primaryContainer: AppColors.primaryDark.withValues(alpha: 0.12),
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondary.withValues(alpha: 0.12),
      tertiary: AppColors.accent,
      surface: AppColors.surfaceLight,
      surfaceContainerHighest: AppColors.cardLight,
      onSurface: const Color(0xFF1C1C1E),
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.error,
      outline: const Color(0xFFE5E5EA),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: const Color(0xFF1C1C1E)),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: const Color(0xFF1C1C1E)),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: const Color(0xFF1C1C1E)),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: const Color(0xFF1C1C1E)),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: const Color(0xFF1C1C1E)),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: const Color(0xFF1C1C1E)),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: const Color(0xFF1C1C1E)),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF1C1C1E)),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: const Color(0xFF1C1C1E)),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF1C1C1E)),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF1C1C1E)),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF1C1C1E)),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF1C1C1E)),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF1C1C1E)),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF1C1C1E)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: Color(0xFF1C1C1E),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
          foregroundColor: AppColors.primaryDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardLight,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.cardLight,
        indicatorColor: AppColors.primaryDark.withValues(alpha: 0.1),
        labelType: NavigationRailLabelType.all,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF1C1C1E)),
        backgroundColor: AppColors.cardLight,
        side: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryDark;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryDark.withValues(alpha: 0.3);
          return const Color(0xFFE5E5EA);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1C1C1E),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E5EA),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
