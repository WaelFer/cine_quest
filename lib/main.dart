import 'package:cine_quest/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- ADDED THIS IMPORT
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // 1. Initialize bindings first (required before calling SystemChrome)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. GLOBAL RESET: Pass an empty list to clear any previous orientation locks.
  // This tells the OS: "Let the user rotate the screen freely."
  SystemChrome.setPreferredOrientations([]);

  runApp(const ProviderScope(child: CineQuestApp()));
}

class CineQuestApp extends StatelessWidget {
  const CineQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineQuest',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212), // Very dark grey background
        // Use Google Fonts for the whole app
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),

        // App Bar styling
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),

        // Color Scheme
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFFE50914), // Netflix-style Red
          secondary: Colors.amber,
        ),
      ),

      home: const MainScreen(),
    );
  }
}
