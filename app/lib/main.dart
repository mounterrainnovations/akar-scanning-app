import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B8CEE);
    const backgroundLight = Color(0xFFF6F7F8);
    const backgroundDark = Color(0xFF101922);

    return MaterialApp(
      title: 'Trippechalo Staff',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          surface: backgroundLight,
          onSurface: Color(0xFF0D141B),
        ),
        textTheme: GoogleFonts.splineSansTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          surface: backgroundDark,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.splineSansTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
