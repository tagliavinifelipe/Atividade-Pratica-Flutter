import 'package:flutter/material.dart';

import '../models/tarefa_model.dart';

/// Formulário de criação/edição exibido no bottom sheet.
///
/// Não acessa o banco: devolve a tarefa preenchida via `Navigator.pop`
/// e quem abriu o sheet decide se cria ou atualiza.
class TarefaFormSheet extends StatefulWidget {
  final TarefaModel? tarefa;

  /// Categoria pré-selecionada ao criar (na edição vale a da tarefa).
  final String categoriaInicial;

  const TarefaFormSheet({
    super.key,
    this.tarefa,
    this.categoriaInicial = TarefaModel.categoriaPadrao,
  });

  @override
  State<TarefaFormSheet> createState() => _TarefaFormSheetState();
}

class _TarefaFormSheetState extends State<TarefaFormSheet> {
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late String _categoria;
  String? _erroTitulo;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tarefa?.titulo);
    _descricaoController = TextEditingController(
      text: widget.tarefa?.descricao,
    );
    _categoria = widget.tarefa?.categoria ?? widget.categoriaInicial;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) {
      setState(() => _erroTitulo = 'Informe um título.');
      return;
    }

    final descricao = _descricaoController.text.trim();
    final tarefa =
        widget.tarefa?.copyWith(
          titulo: titulo,
          descricao: descricao,
          categoria: _categoria,
        ) ??
        TarefaModel(
          titulo: titulo,
          descricao: descricao,
          categoria: _categoria,
        );

    Navigator.pop(context, tarefa);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        // Teclado (viewInsets) + barra de navegação do sistema (padding):
        // no Android 15+ o app é edge-to-edge e a barra cobriria o botão.
        bottom:
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _editando ? 'Editar Tarefa' : 'Nova Tarefa',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tituloController,
            autofocus: !_editando,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Título',
              errorText: _erroTitulo,
            ),
            onChanged: (_) {
              if (_erroTitulo != null) setState(() => _erroTitulo = null);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descricaoController,
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _categoria,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [
              for (final categoria in TarefaModel.categorias)
                DropdownMenuItem(value: categoria, child: Text(categoria)),
            ],
            onChanged: (valor) {
              if (valor != null) setState(() => _categoria = valor);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _salvar,
            child: Text(_editando ? 'Atualizar' : 'Salvar'),
          ),
        ],
      ),
    );
  }
}
