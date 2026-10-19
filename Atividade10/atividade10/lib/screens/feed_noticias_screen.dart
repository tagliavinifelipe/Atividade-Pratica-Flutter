import 'package:flutter/material.dart';

import '../models/noticia_model.dart';
import '../services/noticia_service.dart';

class FeedNoticiasScreen extends StatefulWidget {
  final NoticiaService? service;

  const FeedNoticiasScreen({super.key, this.service});

  @override
  State<FeedNoticiasScreen> createState() => _FeedNoticiasScreenState();
}

class _FeedNoticiasScreenState extends State<FeedNoticiasScreen> {
  late final NoticiaService _service;

  List<NoticiaModel> _noticias = [];
  bool _isLoading = true;
  String? _mensagemErro;
  String _filtro = '';

  List<NoticiaModel> get _noticiasFiltradas {
    final termo = _filtro.trim().toLowerCase();
    if (termo.isEmpty) return _noticias;
    return _noticias
        .where((noticia) => noticia.titulo.toLowerCase().contains(termo))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NoticiaService();
    _carregarFeed();
  }

  Future<void> _carregarFeed() async {
    setState(() {
      _isLoading = true;
      _mensagemErro = null;
    });

    try {
      final noticias = await _service.buscarNoticias();
      if (!mounted) return;
      setState(() {
        _noticias = noticias;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensagemErro = 'Erro: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed de Notícias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: _carregarFeed,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por título',
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() {
                  _filtro = valor;
                });
              },
            ),
          ),
          Expanded(child: _construirCorpo()),
        ],
      ),
    );
  }

  Widget _construirCorpo() {
    // Estado: Carregando
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado: Erro
    if (_mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _mensagemErro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarFeed,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Estado: Vazio
    if (_noticias.isEmpty) {
      return const Center(child: Text('Nenhuma notícia encontrada.'));
    }

    final noticiasFiltradas = _noticiasFiltradas;
    if (noticiasFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma notícia corresponde à busca.'));
    }

    // Estado: Sucesso
    return ListView.builder(
      itemCount: noticiasFiltradas.length,
      itemBuilder: (context, index) {
        final noticia = noticiasFiltradas[index];
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
            subtitle: Text(
              noticia.resumo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
