import 'dart:io';

import 'package:flutter/material.dart';

/// Tag compartilhada pelo avatar e pela tela cheia para a animação Hero.
const String kHeroFotoPerfil = 'foto-perfil';

class FotoTelaCheiaScreen extends StatelessWidget {
  const FotoTelaCheiaScreen({super.key, required this.imagem});

  final File imagem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Foto de Perfil'),
      ),
      body: Center(
        child: Hero(
          tag: kHeroFotoPerfil,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.file(imagem, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
