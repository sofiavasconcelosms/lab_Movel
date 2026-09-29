import 'package:flutter/material.dart';

import 'screens/lista_contatos_page.dart';

void main() {
  runApp(const ListaContatosApp());
}

class ListaContatosApp extends StatelessWidget {
  const ListaContatosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de contatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF245C4C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ListaContatosPage(),
    );
  }
}
