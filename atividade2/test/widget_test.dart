import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividade2/main.dart';

String quantidadeAtual(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('quantidade'))).data!;
}

void main() {
  testWidgets('renderiza titulo, produto e quantidade inicial 1',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Seleção de Itens'), findsOneWidget);
    expect(find.text('Smartphone Galaxy S24'), findsOneWidget);
    expect(quantidadeAtual(tester), '1');
  });
}
