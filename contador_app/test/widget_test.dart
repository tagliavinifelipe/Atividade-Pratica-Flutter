// Testes básicos cobrindo os 3 desafios da aula.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:contador_app/main.dart';

void main() {
  testWidgets('Nível 1: botão Reset zera o contador', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Incrementa 3 vezes.
    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.tap(fab);
    await tester.tap(fab);
    await tester.pump();

    expect(find.text('3'), findsOneWidget);

    // Aperta Reset.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Nível 2: cor muda entre pares (azul) e ímpares (vermelho)',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    // Estado inicial: 0 é par -> azul.
    Text numero = tester.widget(find.text('0'));
    expect(numero.style?.color, Colors.blue.shade700);

    // Clica uma vez: 1 -> vermelho.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    numero = tester.widget(find.text('1'));
    expect(numero.style?.color, Colors.red.shade600);

    // Mais um: 2 -> azul de novo.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    numero = tester.widget(find.text('2'));
    expect(numero.style?.color, Colors.blue.shade700);
  });

  testWidgets('Nível 3: FAB desativa ao chegar em 10', (tester) async {
    await tester.pumpWidget(const MyApp());

    final fab = find.byType(FloatingActionButton);

    // Clica 10 vezes.
    for (var i = 0; i < 10; i++) {
      await tester.tap(fab);
      await tester.pump();
    }

    expect(find.text('10'), findsOneWidget);

    // onPressed deve estar null.
    final FloatingActionButton fabWidget = tester.widget(fab);
    expect(fabWidget.onPressed, isNull);

    // Aviso de limite aparece.
    expect(find.textContaining('Limite atingido'), findsOneWidget);
  });
}
