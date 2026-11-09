import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tarefa_model.dart';

class DatabaseHelper {
  // Singleton: uma única instância (e uma única conexão) para o app todo.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Quando definido, substitui o arquivo padrão (usado só pelos testes).
  static String? _caminhoTeste;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tarefas_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = _caminhoTeste ?? join(await getDatabasesPath(), filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        concluida INTEGER NOT NULL,
        categoria TEXT NOT NULL DEFAULT 'Geral'
      )
    ''');
  }

  // v1 -> v2: coluna categoria. Tarefas antigas ficam em 'Geral'.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE tarefas ADD COLUMN categoria TEXT NOT NULL DEFAULT 'Geral'",
      );
    }
  }

  /// Fecha a conexão atual e faz a próxima abertura usar [caminho]
  /// (por padrão, um banco em memória limpo).
  @visibleForTesting
  static Future<void> reiniciarParaTeste({
    String caminho = inMemoryDatabasePath,
  }) async {
    await _database?.close();
    _database = null;
    _caminhoTeste = caminho;
  }

  Future<int> criarTarefa(TarefaModel tarefa) async {
    final db = await database;
    return await db.insert('tarefas', tarefa.toMap());
  }

  /// Lista as tarefas filtrando no próprio SQL: [categoria] exata e/ou
  /// [busca] (trecho do título ou da descrição). Filtros nulos são ignorados.
  Future<List<TarefaModel>> listarTarefas({
    String? categoria,
    String? busca,
  }) async {
    final db = await database;

    final condicoes = <String>[];
    final args = <Object>[];
    if (categoria != null) {
      condicoes.add('categoria = ?');
      args.add(categoria);
    }
    final termo = busca?.trim() ?? '';
    if (termo.isNotEmpty) {
      final padrao = '%${_escaparLike(termo)}%';
      condicoes.add(
        r"(titulo LIKE ? ESCAPE '\' OR descricao LIKE ? ESCAPE '\')",
      );
      args.addAll([padrao, padrao]);
    }

    final result = await db.query(
      'tarefas',
      where: condicoes.isEmpty ? null : condicoes.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
    return result.map((json) => TarefaModel.fromMap(json)).toList();
  }

  // Faz %, _ e \ digitados pelo usuário valerem como texto literal no LIKE.
  static String _escaparLike(String termo) {
    return termo
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  // Contagem geral, sem filtro: alimenta o "X/Y concluídas" do AppBar.
  Future<({int total, int concluidas})> contarTarefas() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total, COALESCE(SUM(concluida), 0) AS concluidas '
      'FROM tarefas',
    );
    final linha = result.first;
    return (
      total: linha['total'] as int,
      concluidas: linha['concluidas'] as int,
    );
  }

  Future<int> atualizarTarefa(TarefaModel tarefa) async {
    final db = await database;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<int> deletarTarefa(int id) async {
    final db = await database;
    return await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}
