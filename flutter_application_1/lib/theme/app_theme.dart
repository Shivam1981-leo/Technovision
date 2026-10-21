import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceCard = Color(0xFF1E293B);
  static const Color surfaceElevated = Color(0xFF273549);
  
  static const Color primaryPink = Color(0xFFE11D48); // Sangini Rose / SOS Red
  static const Color primaryPinkGlow = Color(0x66E11D48);
  static const Color secondaryViolet = Color(0xFF8B5CF6);
  static const Color accentIndigo = Color(0xFF6366F1);
  
  static const Color statusEmerald = Color(0xFF10B981); // Verified Safe
  static const Color statusAmber = Color(0xFFF59E0B);   // Tier 2 / Caution
  static const Color statusCyan = Color(0xFF06B6D4);    // Peer Mesh
  static const Color statusRose = Color(0xFFF43F5E);    // Active Alert
  
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color border = Color(0xFF334155);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      background: background,
      surface: surface,
      primary: primaryPink,
      secondary: secondaryViolet,
      tertiary: statusCyan,
      error: statusRose,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: border, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primaryPink,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),
  );
}
