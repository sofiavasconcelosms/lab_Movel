import 'package:flutter/material.dart';

import 'screens/lista_tarefas_page.dart';

void main() {
  runApp(const ListaDeTarefasApp());
}

class ListaDeTarefasApp extends StatelessWidget {
  const ListaDeTarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF426B57),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ListaTarefasPage(),
    );
  }
}
