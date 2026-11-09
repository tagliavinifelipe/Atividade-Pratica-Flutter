import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tarefa_model.dart';
import '../widgets/tarefa_form_sheet.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  List<TarefaModel> _tarefas = [];
  ({int total, int concluidas}) _contagem = (total: 0, concluidas: 0);
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    final tarefas = await DatabaseHelper.instance.listarTarefas();
    final contagem = await DatabaseHelper.instance.contarTarefas();
    if (!mounted) return;
    setState(() {
      _tarefas = tarefas;
      _contagem = contagem;
      _carregando = false;
    });
  }

  Future<void> _abrirFormulario([TarefaModel? tarefa]) async {
    final resultado = await showModalBottomSheet<TarefaModel>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TarefaFormSheet(tarefa: tarefa),
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
      ),
      body: _construirCorpo(),
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
      return const Center(child: Text('Nenhuma tarefa cadastrada.'));
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
            subtitle: Text(tarefa.descricao),
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
