import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/inventory_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const StockrApp());
}

class StockrApp extends StatelessWidget {
  const StockrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryProvider()..loadItems(),
      child: MaterialApp(
        title: 'Stockr',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const bgColor = Color(0xFF0D0F14);
    const surfaceColor = Color(0xFF171A22);
    const cardColor = Color(0xFF1E2230);
    const accentColor = Color(0xFF00E5A0);
    const accentWarm = Color(0xFFFF6B35);
    const textPrimary = Color(0xFFF0F2F7);
    const textSecondary = Color(0xFF8891A8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: accentWarm,
        surface: surfaceColor,
        background: bgColor,
        onPrimary: Color(0xFF0D0F14),
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        error: Color(0xFFFF4D6D),
      ),
      cardColor: cardColor,
      textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          color: textPrimary,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2F42)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2F42)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(color: textSecondary),
        hintStyle: GoogleFonts.dmSans(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: bgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: accentColor.withOpacity(0.2),
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: textSecondary),
        side: const BorderSide(color: Color(0xFF2A2F42)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerColor: const Color(0xFF1E2230),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
