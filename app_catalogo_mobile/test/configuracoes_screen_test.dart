import 'package:app_catalogo_mobile/screens/configuracoes_screen.dart';
import 'package:app_catalogo_mobile/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late List<bool> temasRecebidos;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    temasRecebidos = [];
  });

  Future<void> montarTela(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConfiguracoesScreen(onTemaAlterado: temasRecebidos.add),
      ),
    );
    await tester.pumpAndSettle();
  }

  String textoDoCampo(WidgetTester tester, String rotulo) {
    final campo = tester.widget<TextField>(
      find.widgetWithText(TextField, rotulo),
    );
    return campo.controller!.text;
  }

  testWidgets('exibe o nome salvo após carregar', (tester) async {
    SharedPreferences.setMockInitialValues({'key_nome_usuario': 'Felipe'});

    await montarTela(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(textoDoCampo(tester, 'Nome do Usuário'), 'Felipe');
  });

  testWidgets('alternar o switch e salvar chama onTemaAlterado(true)', (
    tester,
  ) async {
    await montarTela(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    await tester.tap(find.text('Salvar Alterações'));
    await tester.pumpAndSettle();

    expect(temasRecebidos, [true]);
    expect(find.text('Preferências salvas com sucesso!'), findsOneWidget);
    expect(await PreferencesService().obterModoEscuro(), isTrue);
  });

  testWidgets('redefinir padrões restaura o nome e envia tema claro', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'key_nome_usuario': 'Felipe',
      'key_modo_escuro': true,
    });
    await montarTela(tester);

    await tester.tap(find.text('Redefinir Padrões'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Redefinir'));
    await tester.pumpAndSettle();

    expect(textoDoCampo(tester, 'Nome do Usuário'), 'Usuário Convidado');
    expect(temasRecebidos, [false]);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(await PreferencesService().obterNomeUsuario(), 'Usuário Convidado');
  });

  testWidgets('cancelar o diálogo mantém as preferências', (tester) async {
    SharedPreferences.setMockInitialValues({'key_nome_usuario': 'Felipe'});
    await montarTela(tester);

    await tester.tap(find.text('Redefinir Padrões'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(textoDoCampo(tester, 'Nome do Usuário'), 'Felipe');
    expect(temasRecebidos, isEmpty);
  });

  group('último acesso', () {
    testWidgets('mostra "Primeiro acesso" sem valor salvo', (tester) async {
      await montarTela(tester);

      expect(find.text('Primeiro acesso'), findsOneWidget);
    });

    testWidgets('mostra o acesso anterior formatado', (tester) async {
      SharedPreferences.setMockInitialValues({
        'key_ultimo_acesso': DateTime(2026, 10, 25, 9, 5).toIso8601String(),
      });

      await montarTela(tester);

      expect(find.text('Último acesso: 25/10/2026 09:05'), findsOneWidget);
    });
  });

  group('histórico de pesquisas', () {
    Future<void> adicionarTermo(WidgetTester tester, String termo) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Termo de pesquisa'),
        termo,
      );
      await tester.tap(find.byTooltip('Adicionar ao histórico'));
      await tester.pumpAndSettle();
    }

    testWidgets('adicionar um termo faz ele aparecer na lista', (tester) async {
      await montarTela(tester);

      await adicionarTermo(tester, 'flutter');

      expect(find.widgetWithText(ListTile, 'flutter'), findsOneWidget);
      final salvo = await PreferencesService().obterHistorico();
      expect(salvo.single['termo'], 'flutter');
    });

    testWidgets('ignora termo vazio ou só com espaços', (tester) async {
      await montarTela(tester);

      await adicionarTermo(tester, '   ');

      expect(find.byIcon(Icons.history), findsNothing);
      expect(find.text('Nenhuma pesquisa registrada.'), findsOneWidget);
      expect(await PreferencesService().obterHistorico(), isEmpty);
    });

    testWidgets('mantém no máximo 10 itens, descartando o mais antigo', (
      tester,
    ) async {
      await montarTela(tester);

      for (var i = 0; i <= 10; i++) {
        await adicionarTermo(tester, 'termo $i');
      }

      final salvo = await PreferencesService().obterHistorico();
      expect(salvo, hasLength(10));
      expect(salvo.first['termo'], 'termo 10');
      expect(salvo.map((item) => item['termo']), isNot(contains('termo 0')));
    });

    testWidgets('remove um item individual', (tester) async {
      await montarTela(tester);
      await adicionarTermo(tester, 'flutter');
      await adicionarTermo(tester, 'dart');

      await tester.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, 'flutter'),
          matching: find.byTooltip('Remover do histórico'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'flutter'), findsNothing);
      expect(find.widgetWithText(ListTile, 'dart'), findsOneWidget);
      final salvo = await PreferencesService().obterHistorico();
      expect(salvo.map((item) => item['termo']), ['dart']);
    });
  });
}
