import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final Function(bool) onTemaAlterado;

  const ConfiguracoesScreen({super.key, required this.onTemaAlterado});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final PreferencesService _prefsService = PreferencesService();
  final TextEditingController _nomeController = TextEditingController();

  bool _modoEscuro = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarPreferencias() async {
    final nome = await _prefsService.obterNomeUsuario();
    final modoEscuro = await _prefsService.obterModoEscuro();

    // A tela pode ter sido fechada enquanto o disco era lido
    if (!mounted) return;
    setState(() {
      _nomeController.text = nome;
      _modoEscuro = modoEscuro;
      _carregando = false;
    });
  }

  Future<void> _salvarPreferencias() async {
    await _prefsService.salvarNomeUsuario(_nomeController.text);
    await _prefsService.salvarModoEscuro(_modoEscuro);
    widget.onTemaAlterado(_modoEscuro);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferências salvas com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Conteúdo rolável: evita overflow quando a tela crescer
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        TextField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do Usuário',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Ativar Modo Escuro'),
                          subtitle: const Text(
                            'Persiste o tema visual selecionado no disco',
                          ),
                          value: _modoEscuro,
                          onChanged: (valor) {
                            setState(() {
                              _modoEscuro = valor;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Ações fixas no rodapé, sempre visíveis
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _salvarPreferencias,
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar Alterações'),
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
