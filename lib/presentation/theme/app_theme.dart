import 'package:flutter/material.dart';

import 'package:nousdeux/core/constants/app_radius.dart';

/// Colors that tell "mine" from "my partner's" (calendar markers, event cards).
@immutable
class CoupleColors extends ThemeExtension<CoupleColors> {
  const CoupleColors({required this.mine, required this.partner});

  final Color mine;
  final Color partner;

  static CoupleColors of(BuildContext context) =>
      Theme.of(context).extension<CoupleColors>()!;

  @override
  CoupleColors copyWith({Color? mine, Color? partner}) =>
      CoupleColors(mine: mine ?? this.mine, partner: partner ?? this.partner);

  @override
  CoupleColors lerp(CoupleColors? other, double t) {
    if (other == null) return this;
    return CoupleColors(
      mine: Color.lerp(mine, other.mine, t)!,
      partner: Color.lerp(partner, other.partner, t)!,
    );
  }
}

/// Warm dark theme for Nous Deux. Single theme used globally.
///
/// Type: Manrope only, bundled in `assets/fonts` (nothing is fetched at
/// runtime). Large numbers and titles use its light weights; labels and
/// buttons its medium and semibold ones. Manrope has no italic, so no style
/// asks for one.
abstract final class AppTheme {
  /// The app's one font family (see pubspec.yaml).
  static const String fontFamily = 'Manrope';

  AppTheme._();

  // Warm dark palette
  static const Color _surface = Color(0xFF1C1917);
  static const Color _surfaceContainerLowest = Color(0xFF141210);
  static const Color _surfaceContainerLow = Color(0xFF221F1C);
  static const Color _surfaceContainer = Color(0xFF292524);
  static const Color _surfaceContainerMid = Color(0xFF36312D);
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
      surfaceContainerLowest: _surfaceContainerLowest,
      surfaceContainerLow: _surfaceContainerLow,
      surfaceContainer: _surfaceContainer,
      surfaceContainerHigh: _surfaceContainerMid,
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

    final base = ThemeData.dark().textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: _onSurface,
      displayColor: _onSurface,
    );

    // Big type goes light and tight; Material's defaults are too loose for it.
    TextStyle? display(
      TextStyle? style,
      FontWeight weight, {
      required double letterSpacing,
    }) => style?.copyWith(
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: 1.1,
    );

    final textTheme = base.copyWith(
      displayLarge: display(
        base.displayLarge,
        FontWeight.w200,
        letterSpacing: -2,
      ),
      displayMedium: display(
        base.displayMedium,
        FontWeight.w200,
        letterSpacing: -1.5,
      ),
      displaySmall: display(
        base.displaySmall,
        FontWeight.w300,
        letterSpacing: -1,
      ),
      headlineLarge: display(
        base.headlineLarge,
        FontWeight.w300,
        letterSpacing: -0.8,
      ),
      headlineMedium: display(
        base.headlineMedium,
        FontWeight.w400,
        letterSpacing: -0.6,
      ),
      headlineSmall: display(
        base.headlineSmall,
        FontWeight.w500,
        letterSpacing: -0.4,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(
        color: _onSurfaceVariant,
        letterSpacing: 0,
        height: 1.45,
      ),
      bodyMedium: base.bodyMedium?.copyWith(letterSpacing: 0, height: 1.45),
      bodySmall: base.bodySmall?.copyWith(letterSpacing: 0.1),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: const [
        CoupleColors(mine: Color(0xFF722F37), partner: Color(0xFFFF8FA3)),
      ],
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: _onSurface),
        actionTextColor: _primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _surface,
        foregroundColor: _onSurface,
        toolbarHeight: 72,
        titleSpacing: 24,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          fontSize: 30,
          color: _onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceContainer,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: _outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
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
            borderRadius: BorderRadius.circular(AppRadius.sm),
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
          borderRadius: BorderRadius.circular(AppRadius.sm),
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
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: _outlineVariant),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? _primary.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? _primary
                : _onSurfaceVariant,
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _outlineVariant,
        thickness: 1,
      ),
      scaffoldBackgroundColor: _surface,
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: _onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: _onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
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
