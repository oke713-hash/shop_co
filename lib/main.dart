import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/cart_provider.dart';
import 'package:provider/provider.dart';

// -- SAKURAYA Color Palette --
const Color kDarkBrown = Color(0xFF433534);
const Color kPink = Color(0xFFEDB1B9);
const Color kLightGreen = Color(0xFFB5DC9C);
const Color kLightYellow = Color(0xFFFCE19B);
const Color kBackground = Color(0xFFFFFdf6);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://lzoajmwvryzslwcaogqt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6b2FqbXd2cnl6c2x3Y2FvZ3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzODYxMDAsImV4cCI6MjA4Nzk2MjEwMH0.bu7gpS62S3eropnA8jRXLuRpS2pzk1VqmvGpKppj9VM',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const SakurayaApp(),
    ),
  );
}

class SakurayaApp extends StatelessWidget {
  const SakurayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakuraya Fashion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPink,
          primary: kPink,
          secondary: kLightGreen,
          surface: Colors.white,
          onPrimary: kDarkBrown,
          onSecondary: kDarkBrown,
          onSurface: kDarkBrown,
        ),
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: kDarkBrown,
            displayColor: kDarkBrown,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kBackground,
          elevation: 0,
          iconTheme: const IconThemeData(color: kDarkBrown),
          titleTextStyle: GoogleFonts.mali(
            color: kDarkBrown,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
