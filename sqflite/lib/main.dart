import 'package:flutter/material.dart';

import 'screens/tarefas_screen.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula 13 - SQLite',
      theme: ThemeData(
        // O roteiro usa Colors.emerald, que não existe no Flutter.
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const TarefasScreen(),
    );
  }
}
