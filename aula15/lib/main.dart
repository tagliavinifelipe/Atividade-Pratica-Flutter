import 'package:flutter/material.dart';

import 'screens/perfil_screen.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula 15 - Câmera e Mídia',
      // O roteiro usa Colors.rose, que não existe no Flutter.
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink),
      home: const PerfilScreen(),
    );
  }
}
