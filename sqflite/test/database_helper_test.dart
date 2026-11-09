import 'dart:io';

import 'package:atividade6/database/database_helper.dart';
import 'package:atividade6/models/tarefa_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final helper = DatabaseHelper.instance;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Cada teste começa com um banco em memória vazio.
  setUp(() => DatabaseHelper.reiniciarParaTeste());
  tearDownAll(() => DatabaseHelper.reiniciarParaTeste());

  Future<int> criar(
    String titulo, {
    String descricao = '',
    String categoria = 'Geral',
    bool concluida = false,
  }) {
    return helper.criarTarefa(
      TarefaModel(
        titulo: titulo,
        descricao: descricao,
        categoria: categoria,
        concluida: concluida,
      ),
    );
  }

  List<String> titulos(List<TarefaModel> tarefas) =>
      tarefas.map((t) => t.titulo).toList();

  group('CRUD', () {
    test('cria e lista em ordem id DESC', () async {
      final id1 = await criar('Primeira');
      final id2 = await criar('Segunda');

      final tarefas = await helper.listarTarefas();

      expect(id2, greaterThan(id1));
      expect(titulos(tarefas), ['Segunda', 'Primeira']);
      expect(tarefas.first.id, id2);
    });

    test('atualiza concluida', () async {
      final id = await criar('Tarefa');
      final tarefa = (await helper.listarTarefas()).single;

      final alteradas = await helper.atualizarTarefa(
        tarefa.copyWith(concluida: true),
      );

      expect(alteradas, 1);
      final atualizada = (await helper.listarTarefas()).single;
      expect(atualizada.id, id);
      expect(atualizada.concluida, isTrue);
    });

    test('deleta pelo id', () async {
      final id1 = await criar('Fica');
      final id2 = await criar('Sai');

      final removidas = await helper.deletarTarefa(id2);

      expect(removidas, 1);
      final tarefas = await helper.listarTarefas();
      expect(tarefas.map((t) => t.id), [id1]);
    });
  });

  group('contarTarefas', () {
    test('banco vazio retorna 0/0', () async {
      final contagem = await helper.contarTarefas();
      expect(contagem.total, 0);
      expect(contagem.concluidas, 0);
    });

    test('conta total e concluídas', () async {
      await criar('A', concluida: true);
      await criar('B');
      await criar('C', concluida: true, categoria: 'Trabalho');

      final contagem = await helper.contarTarefas();

      expect(contagem.total, 3);
      expect(contagem.concluidas, 2);
    });
  });

  group('filtros', () {
    setUp(() async {
      await criar(
        'Relatório',
        descricao: 'Enviar ao chefe',
        categoria: 'Trabalho',
      );
      await criar(
        'Academia',
        descricao: 'Treino de perna',
        categoria: 'Pessoal',
      );
      await criar(
        'Prova',
        descricao: 'Revisar relatório',
        categoria: 'Estudos',
      );
      await criar('Desconto 50%', descricao: 'Cupom', categoria: 'Pessoal');
      await criar(
        'Desconto 50 reais',
        descricao: 'Cupom',
        categoria: 'Pessoal',
      );
    });

    test('filtra por categoria', () async {
      final pessoais = await helper.listarTarefas(categoria: 'Pessoal');
      expect(titulos(pessoais), [
        'Desconto 50 reais',
        'Desconto 50%',
        'Academia',
      ]);
      expect(await helper.listarTarefas(categoria: 'Geral'), isEmpty);
    });

    test('busca no título', () async {
      final resultado = await helper.listarTarefas(busca: 'academ');
      expect(titulos(resultado), ['Academia']);
    });

    test('busca na descrição', () async {
      final resultado = await helper.listarTarefas(busca: 'perna');
      expect(titulos(resultado), ['Academia']);
    });

    test('busca combinada com categoria usa AND', () async {
      // "relatório" aparece no título de uma e na descrição de outra.
      expect(titulos(await helper.listarTarefas(busca: 'relatório')), [
        'Prova',
        'Relatório',
      ]);
      expect(
        titulos(
          await helper.listarTarefas(busca: 'relatório', categoria: 'Estudos'),
        ),
        ['Prova'],
      );
    });

    test('% e _ digitados são literais, não curingas', () async {
      expect(titulos(await helper.listarTarefas(busca: '50%')), [
        'Desconto 50%',
      ]);
      expect(await helper.listarTarefas(busca: 'Desconto_'), isEmpty);
    });

    test('busca vazia ou só com espaços não filtra', () async {
      expect(await helper.listarTarefas(busca: '   '), hasLength(5));
    });
  });

  group('migração', () {
    late Directory pasta;
    late String caminho;

    setUp(() async {
      pasta = await Directory.systemTemp.createTemp('tarefas_migracao');
      caminho = join(pasta.path, 'tarefas_app.db');
    });

    tearDown(() async {
      await DatabaseHelper.reiniciarParaTeste();
      await pasta.delete(recursive: true);
    });

    test('v1 -> v2 adiciona categoria Geral aos registros antigos', () async {
      // Banco como a versão base do roteiro deixava no aparelho.
      final antigo = await databaseFactory.openDatabase(
        caminho,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) => db.execute('''
            CREATE TABLE tarefas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              titulo TEXT NOT NULL,
              descricao TEXT NOT NULL,
              concluida INTEGER NOT NULL
            )
          '''),
        ),
      );
      await antigo.insert('tarefas', {
        'titulo': 'Antiga',
        'descricao': 'Criada na v1',
        'concluida': 1,
      });
      await antigo.close();

      await DatabaseHelper.reiniciarParaTeste(caminho: caminho);
      final tarefas = await helper.listarTarefas();

      expect(tarefas, hasLength(1));
      expect(tarefas.single.titulo, 'Antiga');
      expect(tarefas.single.concluida, isTrue);
      expect(tarefas.single.categoria, 'Geral');

      final db = await helper.database;
      expect(await db.getVersion(), 2);

      // E a coluna nova funciona para registros novos.
      await criar('Nova', categoria: 'Trabalho');
      expect(titulos(await helper.listarTarefas(categoria: 'Trabalho')), [
        'Nova',
      ]);
    });
  });
}
