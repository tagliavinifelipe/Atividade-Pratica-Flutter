import 'package:atividade6/models/tarefa_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TarefaModel', () {
    test('toMap converte concluida true em 1', () {
      final tarefa = TarefaModel(
        id: 7,
        titulo: 'Estudar',
        descricao: 'SQLite',
        concluida: true,
        categoria: 'Estudos',
      );

      expect(tarefa.toMap(), {
        'id': 7,
        'titulo': 'Estudar',
        'descricao': 'SQLite',
        'concluida': 1,
        'categoria': 'Estudos',
      });
    });

    test('toMap converte concluida false em 0', () {
      final tarefa = TarefaModel(titulo: 'A', descricao: 'B');
      expect(tarefa.toMap()['concluida'], 0);
    });

    test('fromMap reconstrói o objeto (ida e volta)', () {
      final original = TarefaModel(
        id: 3,
        titulo: 'Mercado',
        descricao: 'Pão e leite',
        concluida: true,
        categoria: 'Pessoal',
      );

      final copia = TarefaModel.fromMap(original.toMap());

      expect(copia.id, 3);
      expect(copia.titulo, 'Mercado');
      expect(copia.descricao, 'Pão e leite');
      expect(copia.concluida, isTrue);
      expect(copia.categoria, 'Pessoal');
    });

    test('fromMap converte 0 em concluida false', () {
      final tarefa = TarefaModel.fromMap({
        'id': 1,
        'titulo': 'A',
        'descricao': 'B',
        'concluida': 0,
        'categoria': 'Geral',
      });
      expect(tarefa.concluida, isFalse);
    });

    test('categoria padrão é Geral (construtor e linha sem a coluna)', () {
      expect(TarefaModel(titulo: 'A', descricao: 'B').categoria, 'Geral');
      expect(
        TarefaModel.fromMap({
          'id': 1,
          'titulo': 'A',
          'descricao': 'B',
          'concluida': 0,
        }).categoria,
        'Geral',
      );
    });

    test('copyWith altera só os campos informados', () {
      final original = TarefaModel(
        id: 5,
        titulo: 'Original',
        descricao: 'Desc',
        categoria: 'Trabalho',
      );

      final alterada = original.copyWith(concluida: true, titulo: 'Novo');

      expect(alterada.id, 5);
      expect(alterada.titulo, 'Novo');
      expect(alterada.descricao, 'Desc');
      expect(alterada.concluida, isTrue);
      expect(alterada.categoria, 'Trabalho');
      expect(original.concluida, isFalse);
    });
  });
}
