import 'dart:async';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tarefa_model.dart';
import '../widgets/tarefa_form_sheet.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen>
    with SingleTickerProviderStateMixin {
  // Aba 0 = "Todas"; as demais seguem TarefaModel.categorias.
  late final TabController _tabController;
  int _abaCarregada = 0;
  // Descarta respostas de consultas antigas que terminem fora de ordem.
  int _ultimaConsulta = 0;

  final _buscaController = TextEditingController();
  Timer? _debounce;

  List<TarefaModel> _tarefas = [];
  ({int total, int concluidas}) _contagem = (total: 0, concluidas: 0);
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TarefaModel.categorias.length + 1,
      vsync: this,
    )..addListener(_aoTrocarAba);
    _carregarTarefas();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _buscaController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String? get _categoriaSelecionada => _tabController.index == 0
      ? null
      : TarefaModel.categorias[_tabController.index - 1];

  void _aoTrocarAba() {
    if (_tabController.index == _abaCarregada) return;
    _abaCarregada = _tabController.index;
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    final consulta = ++_ultimaConsulta;
    final tarefas = await DatabaseHelper.instance.listarTarefas(
      categoria: _categoriaSelecionada,
      busca: _buscaController.text,
    );
    final contagem = await DatabaseHelper.instance.contarTarefas();
    if (!mounted || consulta != _ultimaConsulta) return;
    setState(() {
      _tarefas = tarefas;
      _contagem = contagem;
      _carregando = false;
    });
  }

  // Espera o usuário parar de digitar antes de consultar o banco.
  void _aoBuscar(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _carregarTarefas);
  }

  void _limparBusca() {
    _debounce?.cancel();
    _buscaController.clear();
    _carregarTarefas();
  }

  Future<void> _abrirFormulario([TarefaModel? tarefa]) async {
    final resultado = await showModalBottomSheet<TarefaModel>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TarefaFormSheet(
        tarefa: tarefa,
        categoriaInicial: _categoriaSelecionada ?? TarefaModel.categoriaPadrao,
      ),
    );
    if (resultado == null) return;

    if (resultado.id == null) {
      await DatabaseHelper.instance.criarTarefa(resultado);
    } else {
      await DatabaseHelper.instance.atualizarTarefa(resultado);
    }
    await _carregarTarefas();
  }

  Future<void> _alternarConcluida(TarefaModel tarefa, bool? valor) async {
    await DatabaseHelper.instance.atualizarTarefa(
      tarefa.copyWith(concluida: valor ?? false),
    );
    await _carregarTarefas();
  }

  Future<void> _deletarTarefa(TarefaModel tarefa) async {
    await DatabaseHelper.instance.deletarTarefa(tarefa.id!);
    await _carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas SQLite'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_contagem.concluidas}/${_contagem.total} concluídas',
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            const Tab(text: 'Todas'),
            for (final categoria in TarefaModel.categorias)
              Tab(text: categoria),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _buscaController,
              builder: (context, valor, _) => TextField(
                controller: _buscaController,
                onChanged: _aoBuscar,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar por título ou descrição',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: valor.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(Icons.clear),
                          onPressed: _limparBusca,
                        ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),
          Expanded(child: _construirCorpo()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova tarefa',
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _construirCorpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_tarefas.isEmpty) {
      // Banco com dados e lista vazia = algum filtro está escondendo tudo.
      return Center(
        child: Text(
          _contagem.total == 0
              ? 'Nenhuma tarefa cadastrada.'
              : 'Nenhuma tarefa encontrada.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _tarefas.length,
      itemBuilder: (context, index) {
        final tarefa = _tarefas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Checkbox(
              value: tarefa.concluida,
              onChanged: (valor) => _alternarConcluida(tarefa, valor),
            ),
            title: Text(
              tarefa.titulo,
              style: TextStyle(
                decoration: tarefa.concluida
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tarefa.descricao),
                const SizedBox(height: 4),
                Chip(
                  label: Text(tarefa.categoria),
                  labelStyle: Theme.of(context).textTheme.labelSmall,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            trailing: IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletarTarefa(tarefa),
            ),
            onTap: () => _abrirFormulario(tarefa),
          ),
        );
      },
    );
  }
}
