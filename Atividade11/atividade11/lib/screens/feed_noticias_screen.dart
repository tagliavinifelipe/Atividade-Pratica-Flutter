import 'package:flutter/material.dart';

import '../models/noticia_model.dart';
import '../services/noticia_service.dart';
import 'detalhe_noticia_screen.dart';

class FeedNoticiasScreen extends StatefulWidget {
  final NoticiaService? service;

  const FeedNoticiasScreen({super.key, this.service});

  @override
  State<FeedNoticiasScreen> createState() => _FeedNoticiasScreenState();
}

class _FeedNoticiasScreenState extends State<FeedNoticiasScreen> {
  late final NoticiaService _service;
  late Future<List<NoticiaModel>> _futureNoticias;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NoticiaService();
    _futureNoticias = _service.buscarNoticias();
  }

  void _recarregar() {
    setState(() {
      _futureNoticias = _service.buscarNoticias();
    });
  }

  void _abrirDetalhes(NoticiaModel noticia) {
    // Passa o objeto ja carregado; o detalhe nao faz nova requisicao.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheNoticiaScreen(noticia: noticia),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notícias')),
      body: FutureBuilder<List<NoticiaModel>>(
        future: _futureNoticias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Erro: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _recarregar,
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final noticias = snapshot.data ?? [];
          if (noticias.isEmpty) {
            return const Center(child: Text('Nenhuma notícia encontrada.'));
          }

          return ListView.builder(
            itemCount: noticias.length,
            itemBuilder: (context, index) {
              final noticia = noticias[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${noticia.id}')),
                  title: Text(
                    noticia.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(noticia.resumo),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _abrirDetalhes(noticia),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
