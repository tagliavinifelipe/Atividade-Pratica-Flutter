import 'package:flutter/material.dart';

import 'screens/feed_noticias_screen.dart';
import 'theme/tema_web2.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aula 11 - Master-Detail',
      debugShowCheckedModeBanner: false,
      theme: criarTemaWeb2(),
      home: const FeedNoticiasScreen(),
    );
  }
}
