import 'package:flutter/material.dart';

import 'screens/geolocalizacao_screen.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula 14 - GPS',
      // A cor "sky" do roteiro não existe no Flutter; usamos lightBlue.
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.lightBlue),
      home: const GeolocalizacaoScreen(),
    );
  }
}
