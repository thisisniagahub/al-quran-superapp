
import 'package:flutter/material.dart';
import 'screens/home_screen_enhanced.dart';

void main() {
  runApp(AlQuranSuperApp());
}

class AlQuranSuperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Quran SuperApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Color(0xFF2D5F3F),
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreenEnhanced(),
    );
  }
}
