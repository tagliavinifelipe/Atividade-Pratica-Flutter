import 'dart:io';

import 'package:flutter/material.dart';

import '../services/media_service.dart';

class PerfilScreen extends StatefulWidget {
  PerfilScreen({super.key, MediaService? mediaService})
    : mediaService = mediaService ?? MediaService();

  final MediaService mediaService;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nomeController = TextEditingController();
  File? _imagemPerfil;

  Future<void> _capturarImagem({required bool daCamera}) async {
    File? imagem;
    try {
      imagem = daCamera
          ? await widget.mediaService.tirarFoto()
          : await widget.mediaService.selecionarDaGaleria();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível obter a imagem.')),
      );
      return;
    }

    if (!mounted) return;
    if (imagem == null) return;

    setState(() {
      _imagemPerfil = imagem;
    });
  }

  void _removerFoto() {
    setState(() {
      _imagemPerfil = null;
    });
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
                  CircleAvatar(
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
