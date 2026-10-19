import 'package:flutter/material.dart';

import '../models/noticia_model.dart';

class DetalheNoticiaScreen extends StatelessWidget {
  final NoticiaModel noticia;
  final bool favorita;

  const DetalheNoticiaScreen({
    super.key,
    required this.noticia,
    this.favorita = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Notícia'),
        actions: [
          IconButton(
            icon: Icon(
              favorita ? Icons.favorite : Icons.favorite_border,
              color: favorita ? Colors.red : null,
            ),
            tooltip: favorita ? 'Remover dos favoritos' : 'Favoritar',
            // Devolve o novo estado para o feed (true = favoritou).
            onPressed: () => Navigator.pop(context, !favorita),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'noticia-${noticia.id}',
              child: Image.network(
                noticia.urlImagem,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 64),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    avatar: const Icon(Icons.person, size: 18),
                    label: Text(noticia.autor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    noticia.titulo,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    noticia.conteudoCompleto,
                    style: textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
