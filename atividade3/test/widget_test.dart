import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividade3/main.dart';

void main() {
  testWidgets('renderiza o catalogo com os produtos iniciais', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Catálogo de Produtos'), findsOneWidget);
    expect(find.text('Itens: 5'), findsOneWidget);
    expect(find.text('Smartphone'), findsOneWidget);
  });

  testWidgets('FAB adiciona um novo produto e atualiza o contador', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MeuApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Itens: 6'), findsOneWidget);
    expect(find.text('Novo Produto 6'), findsOneWidget);
  });

  testWidgets('deslizar o card para a esquerda remove o produto', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MeuApp());

    await tester.drag(find.text('Smartphone'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Itens: 4'), findsOneWidget);
    expect(find.text('Smartphone removido'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Smartphone'), findsNothing);
  });

  testWidgets('tocar no card abre os detalhes e o botao volta ao catalogo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MeuApp());

    await tester.tap(find.text('Notebook'));
    await tester.pumpAndSettle();

    expect(find.text('Voltar ao Catálogo'), findsOneWidget);
    expect(find.text('ID: 2'), findsOneWidget);

    await tester.tap(find.text('Voltar ao Catálogo'));
    await tester.pumpAndSettle();

    expect(find.text('Voltar ao Catálogo'), findsNothing);
    expect(find.text('Catálogo de Produtos'), findsOneWidget);
    expect(find.text('Itens: 5'), findsOneWidget);
  });
}
