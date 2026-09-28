import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividade2/main.dart';

String quantidadeAtual(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('quantidade'))).data!;
}

Future<void> tocarAdicionar(WidgetTester tester, int vezes) async {
  for (var i = 0; i < vezes; i++) {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  }
}

Future<void> abrirResumo(WidgetTester tester) async {
  await tester.tap(find.text('Avançar para Resumo'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renderiza titulo, produto e quantidade inicial 1',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Seleção de Itens'), findsOneWidget);
    expect(find.text('Smartphone Galaxy S24'), findsOneWidget);
    expect(quantidadeAtual(tester), '1');
  });

  testWidgets('incrementa e nao decrementa abaixo de 1',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(quantidadeAtual(tester), '1');

    await tocarAdicionar(tester, 1);
    expect(quantidadeAtual(tester), '2');
  });

  testWidgets('zerar contador volta a quantidade para 1',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());
    await tocarAdicionar(tester, 2);
    expect(quantidadeAtual(tester), '3');

    await tester.tap(find.text('Zerar Contador'));
    await tester.pump();
    expect(quantidadeAtual(tester), '1');
  });

  testWidgets('avancar abre TelaResumo com os dados do pedido',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());
    await tocarAdicionar(tester, 1);

    await abrirResumo(tester);

    expect(find.text('Resumo do Pedido'), findsOneWidget);
    expect(find.text('Item: Smartphone Galaxy S24'), findsOneWidget);
    expect(find.text('Quantidade Selecionada: 2'), findsOneWidget);
  });
}
