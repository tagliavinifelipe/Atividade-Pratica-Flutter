import 'package:atividade6/database/database_helper.dart';
import 'package:atividade6/main.dart';
import 'package:atividade6/models/tarefa_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() => DatabaseHelper.reiniciarParaTeste());
  tearDownAll(() => DatabaseHelper.reiniciarParaTeste());

  // O banco FFI faz I/O de verdade, que o relógio falso do testWidgets não
  // avança sozinho. Alterna tempo real (runAsync) e pump até [finder]
  // aparecer (ou sumir, com [ausente]), com limite para falhar em vez de
  // travar.
  Future<void> esperarAte(
    WidgetTester tester,
    Finder finder, {
    bool ausente = false,
  }) async {
    for (var i = 0; i < 50; i++) {
      await tester.pump();
      if (finder.evaluate().isEmpty == ausente) return;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    }
    fail('Tempo esgotado esperando por $finder');
  }

  Future<void> abrirApp(WidgetTester tester) async {
    // Abre o banco fora do relógio falso antes de montar a tela.
    await tester.runAsync(() => DatabaseHelper.instance.database);
    await tester.pumpWidget(const MeuApp());
  }

  testWidgets('exibe estado vazio e contador zerado', (tester) async {
    await abrirApp(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await esperarAte(tester, find.text('Nenhuma tarefa cadastrada.'));

    expect(find.text('0/0 concluídas'), findsOneWidget);
  });

  testWidgets('adicionar pelo FAB mostra a tarefa e atualiza o contador', (
    tester,
  ) async {
    await abrirApp(tester);
    await esperarAte(tester, find.text('Nenhuma tarefa cadastrada.'));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Título'),
      'Comprar pão',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Descrição'),
      'Padaria da esquina',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    await esperarAte(tester, find.text('0/1 concluídas'));
    expect(find.text('Comprar pão'), findsOneWidget);
    expect(find.text('Padaria da esquina'), findsOneWidget);
    expect(find.text('Nenhuma tarefa cadastrada.'), findsNothing);
  });

  testWidgets('marcar o checkbox conclui a tarefa no banco', (tester) async {
    await tester.runAsync(
      () => DatabaseHelper.instance.criarTarefa(
        TarefaModel(titulo: 'Lavar louça', descricao: ''),
      ),
    );
    await abrirApp(tester);
    await esperarAte(tester, find.text('0/1 concluídas'));

    await tester.tap(find.byType(Checkbox));
    await esperarAte(tester, find.text('1/1 concluídas'));

    final titulo = tester.widget<Text>(find.text('Lavar louça'));
    expect(titulo.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('aba de categoria filtra e contador continua geral', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await DatabaseHelper.instance.criarTarefa(
        TarefaModel(titulo: 'Relatório', descricao: '', categoria: 'Trabalho'),
      );
      await DatabaseHelper.instance.criarTarefa(
        TarefaModel(titulo: 'Academia', descricao: '', categoria: 'Pessoal'),
      );
    });
    await abrirApp(tester);
    await esperarAte(tester, find.text('Academia'));

    await tester.tap(find.widgetWithText(Tab, 'Trabalho'));
    await esperarAte(tester, find.text('Academia'), ausente: true);

    expect(find.text('Relatório'), findsOneWidget);
    expect(find.text('0/2 concluídas'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Estudos'));
    await esperarAte(tester, find.text('Nenhuma tarefa encontrada.'));
    expect(find.text('0/2 concluídas'), findsOneWidget);
  });

  testWidgets('busca filtra a lista após o debounce', (tester) async {
    await tester.runAsync(() async {
      await DatabaseHelper.instance.criarTarefa(
        TarefaModel(titulo: 'Estudar SQL', descricao: 'Capítulo de LIKE'),
      );
      await DatabaseHelper.instance.criarTarefa(
        TarefaModel(titulo: 'Passear', descricao: 'Parque'),
      );
    });
    await abrirApp(tester);
    await esperarAte(tester, find.text('Passear'));

    await tester.enterText(find.byType(TextField), 'like');
    // Ainda dentro dos 300 ms: nada mudou.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Passear'), findsOneWidget);

    // Passa o debounce e espera a consulta voltar.
    await tester.pump(const Duration(milliseconds: 300));
    await esperarAte(tester, find.text('Passear'), ausente: true);
    expect(find.text('Estudar SQL'), findsOneWidget);

    await tester.tap(find.byTooltip('Limpar busca'));
    await esperarAte(tester, find.text('Passear'));
    expect(find.text('Estudar SQL'), findsOneWidget);
  });
}
