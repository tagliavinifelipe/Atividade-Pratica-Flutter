import 'dart:io';

import 'package:flutter/material.dart';

import '../services/media_service.dart';
import '../services/perfil_storage.dart';
import 'foto_tela_cheia_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key, this.mediaService, this.perfilStorage});

  /// Permitem injetar serviços falsos nos testes. Se forem nulos, usa os reais.
  final MediaService? mediaService;
  final PerfilStorage? perfilStorage;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late final MediaService _mediaService = widget.mediaService ?? MediaService();
  late final PerfilStorage _perfilStorage =
      widget.perfilStorage ?? PerfilStorage();
  File? _imagemPerfil;
  final _nomeController = TextEditingController(text: 'Diego Menegassi');

  @override
  void initState() {
    super.initState();
    _carregarFotoSalva();
  }

  // Desafio avançado: recupera a foto salva ao abrir o app.
  Future<void> _carregarFotoSalva() async {
    final File? foto = await _perfilStorage.carregarFoto();
    if (!mounted || foto == null) return;
    setState(() {
      _imagemPerfil = foto;
    });
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _capturarImagem(bool daCamera) async {
    Navigator.pop(context);

    File? imagem;
    try {
      imagem = daCamera
          ? await _mediaService.tirarFoto()
          : await _mediaService.selecionarDaGaleria();
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem('Não foi possível obter a imagem.');
      return;
    }

    if (!mounted) return;
    if (imagem != null) {
      // Copia a foto para fora do cache e salva o caminho.
      File fotoSalva = imagem;
      try {
        fotoSalva = await _perfilStorage.salvarFoto(imagem);
      } catch (_) {
        if (!mounted) return;
        _mostrarMensagem('A foto não pôde ser salva para a próxima abertura.');
      }

      if (!mounted) return;
      setState(() {
        _imagemPerfil = fotoSalva;
      });
    }
  }

  // Desafio básico: remove a foto e o caminho salvo.
  Future<void> _removerFoto() async {
    Navigator.pop(context);
    setState(() {
      _imagemPerfil = null;
    });
    await _perfilStorage.removerFoto();
  }

  // Desafio intermediário: foto em tela cheia com Hero e zoom.
  void _abrirTelaCheia() {
    final File? imagem = _imagemPerfil;
    if (imagem == null) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FotoTelaCheiaScreen(imagem: imagem),
      ),
    );
  }

  void _exibirOpcoesMidia() {
    showModalBottomSheet<void>(
      context: context,
      // Sem altura fixa (o roteiro usa 160): a 3ª opção não cabia.
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.pink),
                title: const Text('Tirar Foto com a Câmera'),
                onTap: () => _capturarImagem(true),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.pink),
                title: const Text('Escolher da Galeria'),
                onTap: () => _capturarImagem(false),
              ),
              if (_imagemPerfil != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover Foto'),
                  onTap: _removerFoto,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Usuário'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _imagemPerfil != null ? _abrirTelaCheia : null,
                    child: Hero(
                      tag: kHeroFotoPerfil,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.pink.shade100,
                        backgroundImage: _imagemPerfil != null
                            ? FileImage(_imagemPerfil!)
                            : null,
                        child: _imagemPerfil == null
                            ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.pink,
                              )
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      onPressed: _exibirOpcoesMidia,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
