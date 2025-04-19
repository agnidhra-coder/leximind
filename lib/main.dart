import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leximind/pages/chat_screen.dart';
import 'package:leximind/pages/connection_screen.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light, // dark icons for Android
  ));

  runApp(
    const ProviderScope(
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LexiMind',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF303030), // Dark grey background
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white, // Primary color for buttons
          onPrimary: Color(0xFF303030), // Text on primary color (buttons)
          secondary: Colors.white70,
          surface: Color(0xFF424242), // Surface color for cards, etc.
          background: Color(0xFF303030), // Background color
        ),
        textTheme: GoogleFonts.lexendTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white, // Set all body text to white
          displayColor: Colors.white, // Set all display text to white
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xFF303030), // Text color on button
            backgroundColor: Colors.white, // Button background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Customize the border radius here
              // You can also add a border if desired:
              // side: const BorderSide(color: Colors.white70, width: 2),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Default icon color
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF212121), // Slightly darker app bar
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF424242), // Card background color
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          fillColor: Color(0xFF424242),
          filled: true,
        ),
      ),
      home: const ChatScreen(),
    );
  }
}
