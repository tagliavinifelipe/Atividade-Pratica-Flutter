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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        concluida INTEGER NOT NULL
      )
    ''');
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

  Future<List<TarefaModel>> listarTarefas() async {
    final db = await database;
    final result = await db.query('tarefas', orderBy: 'id DESC');
    return result.map((json) => TarefaModel.fromMap(json)).toList();
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
