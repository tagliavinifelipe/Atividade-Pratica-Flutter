import 'package:flutter/material.dart';

import 'screens/feed_noticias_screen.dart';
import 'theme/tema_xp.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aula 10 - Consumo de APIs',
      debugShowCheckedModeBanner: false,
      theme: criarTemaXp(),
      home: const FeedNoticiasScreen(),
    );
  }
}
