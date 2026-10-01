import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EggYolkApp());
}

class EggYolkApp extends StatelessWidget {
  const EggYolkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Egg Yolk Color Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAF5EB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8A020),
          primary: const Color(0xFFE8A020),
          surface: const Color(0xFFFAF5EB),
        ),
        textTheme: GoogleFonts.kanitTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
