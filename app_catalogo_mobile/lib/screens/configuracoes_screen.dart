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
  final TextEditingController _pesquisaController = TextEditingController();

  static const int _limiteHistorico = 10;

  bool _modoEscuro = false;
  bool _carregando = true;
  DateTime? _ultimoAcesso;
  List<Map<String, dynamic>> _historico = [];

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarPreferencias() async {
    final nome = await _prefsService.obterNomeUsuario();
    final modoEscuro = await _prefsService.obterModoEscuro();
    final historico = await _prefsService.obterHistorico();

    // Lê o acesso anterior antes de sobrescrever com o acesso atual
    final ultimoAcesso = await _prefsService.obterUltimoAcesso();
    await _prefsService.salvarUltimoAcesso(DateTime.now());

    // A tela pode ter sido fechada enquanto o disco era lido
    if (!mounted) return;
    setState(() {
      _nomeController.text = nome;
      _modoEscuro = modoEscuro;
      _ultimoAcesso = ultimoAcesso;
      _historico = historico;
      _carregando = false;
    });
  }

  Future<void> _adicionarPesquisa() async {
    final termo = _pesquisaController.text.trim();
    if (termo.isEmpty) return;

    setState(() {
      // Mais recente primeiro; descarta o mais antigo ao passar do limite
      _historico.insert(0, {
        'termo': termo,
        'data': DateTime.now().toIso8601String(),
      });
      if (_historico.length > _limiteHistorico) {
        _historico.removeLast();
      }
      _pesquisaController.clear();
    });
    await _prefsService.salvarHistorico(_historico);
  }

  Future<void> _removerPesquisa(int indice) async {
    setState(() {
      _historico.removeAt(indice);
    });
    await _prefsService.salvarHistorico(_historico);
  }

  Future<void> _redefinirPadroes() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Redefinir Padrões'),
        content: const Text(
          'Todas as preferências salvas serão apagadas. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Redefinir'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;
    await _prefsService.limparTudo();

    if (!mounted) return;
    setState(() {
      _nomeController.text = 'Usuário Convidado';
      _modoEscuro = false;
      _historico = [];
    });
    widget.onTemaAlterado(false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferências redefinidas para o padrão.')),
    );
  }

  String _formatarData(DateTime data) {
    String doisDigitos(int valor) => valor.toString().padLeft(2, '0');

    return '${doisDigitos(data.day)}/${doisDigitos(data.month)}/${data.year} '
        '${doisDigitos(data.hour)}:${doisDigitos(data.minute)}';
  }

  // Os itens vêm do disco, então a data pode estar ausente ou inválida
  String _descreverData(Object? valor) {
    final data = valor is String ? DateTime.tryParse(valor) : null;
    return data == null ? '' : _formatarData(data);
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
                        const SizedBox(height: 24),
                        Text(
                          'Histórico de Pesquisas',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pesquisaController,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _adicionarPesquisa(),
                                decoration: const InputDecoration(
                                  labelText: 'Termo de pesquisa',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: _adicionarPesquisa,
                              icon: const Icon(Icons.add),
                              tooltip: 'Adicionar ao histórico',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_historico.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Nenhuma pesquisa registrada.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          for (var i = 0; i < _historico.length; i++)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.history),
                              title: Text('${_historico[i]['termo'] ?? ''}'),
                              subtitle: Text(
                                _descreverData(_historico[i]['data']),
                              ),
                              trailing: IconButton(
                                onPressed: () => _removerPesquisa(i),
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Remover do histórico',
                              ),
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
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _redefinirPadroes,
                          icon: const Icon(Icons.restore),
                          label: const Text('Redefinir Padrões'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _ultimoAcesso == null
                              ? 'Primeiro acesso'
                              : 'Último acesso: ${_formatarData(_ultimoAcesso!)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
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
