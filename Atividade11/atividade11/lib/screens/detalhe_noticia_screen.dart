import 'package:flutter/material.dart';

import '../models/comentario_model.dart';
import '../models/noticia_model.dart';
import '../services/noticia_service.dart';

class DetalheNoticiaScreen extends StatefulWidget {
  final NoticiaModel noticia;
  final bool favorita;
  final NoticiaService? service;

  const DetalheNoticiaScreen({
    super.key,
    required this.noticia,
    this.favorita = false,
    this.service,
  });

  @override
  State<DetalheNoticiaScreen> createState() => _DetalheNoticiaScreenState();
}

class _DetalheNoticiaScreenState extends State<DetalheNoticiaScreen> {
  late final Future<List<ComentarioModel>> _futureComentarios;

  @override
  void initState() {
    super.initState();
    final service = widget.service ?? NoticiaService();
    _futureComentarios = service.buscarComentarios(widget.noticia.id);
  }

  @override
  Widget build(BuildContext context) {
    final noticia = widget.noticia;
    final favorita = widget.favorita;
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
                  const SizedBox(height: 24),
                  Text(
                    'Comentários',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _construirComentarios(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirComentarios() {
    return FutureBuilder<List<ComentarioModel>>(
      future: _futureComentarios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Erro ao carregar comentários: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final comentarios = snapshot.data ?? [];
        if (comentarios.isEmpty) {
          return const Text('Nenhum comentário ainda.');
        }

        // Column + map em vez de ListView aninhado no SingleChildScrollView.
        return Column(
          children: comentarios
              .map((comentario) => _ComentarioCard(comentario: comentario))
              .toList(),
        );
      },
    );
  }
}

class _ComentarioCard extends StatelessWidget {
  final ComentarioModel comentario;

  const _ComentarioCard({required this.comentario});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comentario.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(comentario.email, style: textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(comentario.texto),
          ],
        ),
      ),
    );
  }
}
