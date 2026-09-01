import 'package:flutter/material.dart';

import 'screens/divisor_home_page.dart';

void main() {
  runApp(const DivisorDeContaApp());
}

class DivisorDeContaApp extends StatelessWidget {
  const DivisorDeContaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo divide conta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 2, 105)),
      ),
      home: const DivisorHomePage(),
    );
  }
}
