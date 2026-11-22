import 'dart:io';

import 'package:flutter/material.dart';

import '../services/media_service.dart';
import '../services/perfil_storage.dart';
import 'foto_tela_cheia_screen.dart';

class PerfilScreen extends StatefulWidget {
  PerfilScreen({
    super.key,
    MediaService? mediaService,
    PerfilStorage? perfilStorage,
  }) : mediaService = mediaService ?? MediaService(),
       perfilStorage = perfilStorage ?? PerfilStorage();

  final MediaService mediaService;
  final PerfilStorage perfilStorage;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nomeController = TextEditingController();
  File? _imagemPerfil;

  @override
  void initState() {
    super.initState();
    _carregarFotoSalva();
  }

  Future<void> _carregarFotoSalva() async {
    final File? foto = await widget.perfilStorage.carregarFoto();
    if (!mounted) return;
    if (foto == null) return;
    setState(() {
      _imagemPerfil = foto;
    });
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _capturarImagem({required bool daCamera}) async {
    File? imagem;
    try {
      imagem = daCamera
          ? await widget.mediaService.tirarFoto()
          : await widget.mediaService.selecionarDaGaleria();
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem('Não foi possível obter a imagem.');
      return;
    }

    if (!mounted) return;
    if (imagem == null) return;

    File fotoFinal = imagem;
    try {
      fotoFinal = await widget.perfilStorage.salvarFoto(imagem);
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem('A foto não pôde ser salva para a próxima abertura.');
    }

    if (!mounted) return;
    setState(() {
      _imagemPerfil = fotoFinal;
    });
  }

  Future<void> _removerFoto() async {
    setState(() {
      _imagemPerfil = null;
    });
    await widget.perfilStorage.removerFoto();
  }

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

  void _mostrarOpcoes() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext contextoSheet) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.pink),
                title: const Text('Tirar Foto com a Câmera'),
                onTap: () {
                  Navigator.pop(contextoSheet);
                  _capturarImagem(daCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.pink),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(contextoSheet);
                  _capturarImagem(daCamera: false);
                },
              ),
              if (_imagemPerfil != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover Foto'),
                  onTap: () {
                    Navigator.pop(contextoSheet);
                    _removerFoto();
                  },
                ),
            ],
          ),
        );
      },
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
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      onPressed: _mostrarOpcoes,
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
