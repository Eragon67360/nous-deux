import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm dark theme for Nous Deux. Single theme used globally.
abstract final class AppTheme {
  AppTheme._();

  // Warm dark palette
  static const Color _surface = Color(0xFF1C1917);
  static const Color _surfaceContainer = Color(0xFF292524);
  static const Color _surfaceContainerHigh = Color(0xFF44403C);
  static const Color _onSurface = Color(0xFFF5F0EB);
  static const Color _onSurfaceVariant = Color(0xFFD6D3D1);
  static const Color _primary = Color(0xFFC4A77D);
  static const Color _onPrimary = Color(0xFF1C1917);
  static const Color _primaryContainer = Color(0xFF57534E);
  static const Color _onPrimaryContainer = Color(0xFFF5F0EB);
  static const Color _error = Color(0xFFF87171);
  static const Color _onError = Color(0xFF450A0A);
  static const Color _outline = Color(0xFF78716C);
  static const Color _outlineVariant = Color(0xFF44403C);

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      surface: _surface,
      onSurface: _onSurface,
      surfaceContainerHighest: _surfaceContainerHigh,
      primary: _primary,
      onPrimary: _onPrimary,
      primaryContainer: _primaryContainer,
      onPrimaryContainer: _onPrimaryContainer,
      secondary: _primary,
      onSecondary: _onPrimary,
      error: _error,
      onError: _onError,
      outline: _outline,
      outlineVariant: _outlineVariant,
      onSurfaceVariant: _onSurfaceVariant,
    );

    final textTheme = GoogleFonts.dmSansTextTheme(
      ThemeData.dark().textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        headlineMedium: const TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: _onSurfaceVariant),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _surface,
        foregroundColor: _onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: _onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceContainer,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: _onSurfaceVariant),
        hintStyle: TextStyle(color: _onSurfaceVariant.withValues(alpha: 0.7)),
      ),
      cardTheme: CardThemeData(
        color: _surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: _outline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        elevation: 0,
        backgroundColor: _surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _primary.withValues(alpha: 0.2),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primary, size: 24);
          }
          return const IconThemeData(color: _onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(color: _primary);
          }
          return textTheme.labelMedium?.copyWith(color: _onSurfaceVariant);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: _outlineVariant,
        thickness: 1,
      ),
      scaffoldBackgroundColor: _surface,
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: _onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: _onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        elevation: 0,
      ),
    );
  }
}
