import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/ecra_login.dart';

void main() {
  runApp(const SoftinsaBadgesApp());
}

class SoftinsaBadgesApp extends StatelessWidget {
  const SoftinsaBadgesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Softinsa Badges',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E5B94),
          primary: const Color(0xFF2E5B94),
          background: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
