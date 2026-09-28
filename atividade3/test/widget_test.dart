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
}
