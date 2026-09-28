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
}
