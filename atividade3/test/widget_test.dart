import 'package:flutter_test/flutter_test.dart';

import 'package:atividade3/main.dart';

void main() {
  testWidgets('MeuApp renderiza sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Catálogo de Produtos'), findsOneWidget);
  });
}
