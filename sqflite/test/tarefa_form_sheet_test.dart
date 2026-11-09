import 'package:atividade6/models/tarefa_model.dart';
import 'package:atividade6/widgets/tarefa_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Abre o sheet como a tela faz e guarda o que ele devolver no pop.
  Future<List<TarefaModel?>> abrirSheet(
    WidgetTester tester, {
    TarefaModel? tarefa,
    String categoriaInicial = TarefaModel.categoriaPadrao,
  }) async {
    final retornos = <TarefaModel?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                retornos.add(
                  await showModalBottomSheet<TarefaModel>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TarefaFormSheet(
                      tarefa: tarefa,
                      categoriaInicial: categoriaInicial,
                    ),
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return retornos;
  }

  Finder campo(String label) =>
      find.widgetWithText(TextField, label, skipOffstage: false);

  testWidgets('título vazio não fecha o sheet e mostra erro', (tester) async {
    final retornos = await abrirSheet(tester);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Tarefa'), findsOneWidget);
    expect(find.text('Informe um título.'), findsOneWidget);
    expect(retornos, isEmpty);
  });

  testWidgets('título só com espaços não fecha o sheet', (tester) async {
    final retornos = await abrirSheet(tester);

    await tester.enterText(campo('Título'), '    ');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Tarefa'), findsOneWidget);
    expect(find.text('Informe um título.'), findsOneWidget);
    expect(retornos, isEmpty);
  });

  testWidgets('salvar devolve a tarefa com texto aparado e categoria', (
    tester,
  ) async {
    final retornos = await abrirSheet(tester, categoriaInicial: 'Estudos');

    await tester.enterText(campo('Título'), '  Ler capítulo 3  ');
    await tester.enterText(campo('Descrição'), 'Livro de Flutter');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Tarefa'), findsNothing);
    final tarefa = retornos.single!;
    expect(tarefa.id, isNull);
    expect(tarefa.titulo, 'Ler capítulo 3');
    expect(tarefa.descricao, 'Livro de Flutter');
    expect(tarefa.categoria, 'Estudos');
  });

  testWidgets('botão não fica atrás da barra de navegação do sistema', (
    tester,
  ) async {
    // Simula o edge-to-edge do Android 15+: barra de 48 px lógicos embaixo.
    final dpr = tester.view.devicePixelRatio;
    tester.view.padding = FakeViewPadding(bottom: 48 * dpr);
    addTearDown(tester.view.resetPadding);
    await abrirSheet(tester);

    final alturaTela = tester.view.physicalSize.height / dpr;
    const barra = 48;
    final botao = tester.getRect(find.widgetWithText(ElevatedButton, 'Salvar'));

    expect(botao.bottom, lessThanOrEqualTo(alturaTela - barra));
  });

  testWidgets('modo edição vem com os campos preenchidos', (tester) async {
    final existente = TarefaModel(
      id: 42,
      titulo: 'Reunião',
      descricao: 'Sala 2',
      concluida: true,
      categoria: 'Trabalho',
    );
    final retornos = await abrirSheet(tester, tarefa: existente);

    expect(find.text('Editar Tarefa'), findsOneWidget);
    expect(find.text('Atualizar'), findsOneWidget);
    expect(find.text('Reunião'), findsOneWidget);
    expect(find.text('Sala 2'), findsOneWidget);
    expect(find.text('Trabalho'), findsOneWidget);

    await tester.enterText(campo('Título'), 'Reunião de equipe');
    await tester.tap(find.text('Atualizar'));
    await tester.pumpAndSettle();

    final tarefa = retornos.single!;
    expect(tarefa.id, 42);
    expect(tarefa.titulo, 'Reunião de equipe');
    expect(tarefa.concluida, isTrue);
    expect(tarefa.categoria, 'Trabalho');
  });
}
