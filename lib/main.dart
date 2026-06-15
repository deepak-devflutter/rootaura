import 'package:flutter/material.dart';
import 'screens/contact_screen.dart';
import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_screen.dart';

void main() {

  runApp(const RootauraNaturalsApp());
}

class RootauraNaturalsApp extends StatelessWidget {
  const RootauraNaturalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rootaura Naturals - Colors of Health, Packed with Nature',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/privacy': (context) => const PrivacyScreen(),
        '/contact': (context) => const ContactScreen(),
      },
    );
  }
}