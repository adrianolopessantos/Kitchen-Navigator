import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kitchen Navigator Version 12 visual foundation.
///
/// The Version 12 design language is intentionally warm, calm and helpful:
/// forest green for guidance, sage for pantry/health, bamboo for food and
/// planning, warm cream backgrounds, and restrained semantic status colors.
abstract final class AppColors {
  // Core brand.
  static const background = Color(0xFFF7F5F0);
  static const backgroundSoft = Color(0xFFFBFAF7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFF2F5F1);
  static const surfaceHighlight = Color(0xFFE8F0EA);

  static const primary = Color(0xFF1F5D3B);
  static const primaryStrong = Color(0xFF16452C);
  static const sage = Color(0xFF6D9773);
  static const bamboo = Color(0xFFC99A4B);
  static const copper = Color(0xFFB87333);
  static const terracotta = Color(0xFFC96E4B);

  // Semantic colors.
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFF9A825);
  static const danger = Color(0xFFD84315);
  static const info = Color(0xFF1E88E5);

  // Typography and structure.
  static const text = Color(0xFF1F2937);
  static const muted = Color(0xFF6B7280);
  static const subtle = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFEDF0EC);

  // Feature identities. These are the source of truth for Version 12.
  static const today = Color(0xFF1F5D3B);
  static const planner = Color(0xFF6B5CA5);
  static const shopping = Color(0xFFE58A38);
  static const pantry = Color(0xFF6D9773);
  static const recipes = Color(0xFFC99A4B);
  static const cooking = Color(0xFFB87333);
  static const nutrition = Color(0xFF2A8D7C);
  static const budget = Color(0xFF388E5A);
  static const household = Color(0xFF4F72B8);
  static const notifications = Color(0xFFF0A51A);
  static const settings = Color(0xFF7A818B);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

abstract final class AppRadius {
  static const small = 12.0;
  static const medium = 16.0;
  static const card = 20.0;
  static const hero = 28.0;
  static const button = 18.0;
  static const dialog = 24.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.sage,
        tertiary: AppColors.bamboo,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.text,
        onError: Colors.white,
      ),
    );

    final poppins = GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: poppins.copyWith(
        headlineLarge: GoogleFonts.poppins(
          color: AppColors.text,
          fontSize: 32,
          height: 1.08,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: AppColors.text,
          fontSize: 25,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.poppins(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: AppColors.text,
          fontSize: 15,
          height: 1.45,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: AppColors.muted,
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x18000000),
        elevation: 1.5,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.card),
          ),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: .12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.poppins(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.muted,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.muted,
            size: states.contains(WidgetState.selected) ? 25 : 23,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryStrong,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(64, 50),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primaryStrong,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: GoogleFonts.poppins(
          color: AppColors.muted,
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.subtle,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.6,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: .12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryStrong,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: const Color(0xFFF4D28A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.dialog),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: AppColors.muted, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.border;
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.button),
          ),
        ),
      ),
    );
  }
}
