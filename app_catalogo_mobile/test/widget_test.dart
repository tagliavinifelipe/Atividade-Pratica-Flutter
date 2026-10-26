import 'package:app_catalogo_mobile/main.dart';
import 'package:app_catalogo_mobile/screens/configuracoes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ThemeMode? temaAtual(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;

  testWidgets('abre a tela de configurações com o tema salvo', (tester) async {
    await tester.pumpWidget(const MeuApp(modoEscuroInicial: true));
    await tester.pumpAndSettle();

    expect(find.byType(ConfiguracoesScreen), findsOneWidget);
    expect(temaAtual(tester), ThemeMode.dark);
  });

  testWidgets('salvar com o modo escuro ativo troca o tema do app', (
    tester,
  ) async {
    await tester.pumpWidget(const MeuApp(modoEscuroInicial: false));
    await tester.pumpAndSettle();
    expect(temaAtual(tester), ThemeMode.light);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    await tester.tap(find.text('Salvar Alterações'));
    await tester.pumpAndSettle();

    expect(temaAtual(tester), ThemeMode.dark);
  });
}
