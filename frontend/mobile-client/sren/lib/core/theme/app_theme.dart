import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final _brandAccent = Colors.tealAccent.shade400;
  static final _surface = const Color(0xFF111418);
  static final _surfaceElevated = const Color(0xFF1A1E22);
  static const _textPrimary = Colors.white;
  static final _textSecondary = Colors.white.withOpacity(0.72);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: _surface,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
        primary: _brandAccent,
        secondary: _brandAccent,
        surface: _surface,
        background: _surface,
        onSurface: _textPrimary,
        onBackground: _textPrimary,
        onPrimary: Colors.black,
        outline: Colors.white.withOpacity(0.12),
      ),
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: _surface,
        elevation: 0,
        titleTextStyle: _buildTextTheme(base.textTheme).titleLarge,
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      cardTheme: CardThemeData(
        color: _surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          ),
          foregroundColor: WidgetStateProperty.all(Colors.black),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.white.withOpacity(0.2);
            }
            return _brandAccent;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: _brandAccent),
        ),
        labelStyle: TextStyle(color: _textSecondary),
        hintStyle: TextStyle(color: _textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceElevated,
        contentTextStyle: _buildTextTheme(base.textTheme).bodyMedium,
        actionTextColor: _brandAccent,
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surfaceElevated,
        selectedItemColor: _brandAccent,
        unselectedItemColor: _textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    const displayFont = 'SF Pro Display';
    const textFont = 'SF Pro Text';

    return base
        .apply(
          bodyColor: _textPrimary,
          displayColor: _textPrimary,
        )
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontFamily: displayFont,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.2,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontFamily: displayFont,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontFamily: textFont,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontFamily: textFont,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontFamily: textFont,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontFamily: textFont,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontFamily: textFont,
            color: _textSecondary,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontFamily: textFont,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        );
  }

  static const emotionColors = <String, Color>{
    'HAPPY': Color(0xFFFFD54F),
    'SAD': Color(0xFF64B5F6),
    'ANGRY': Color(0xFFE57373),
    'FEAR': Color(0xFF9575CD),
    'NEUTRAL': Color(0xFFB0BEC5),
    'SURPRISE': Color(0xFF4DD0E1),
  };
}
