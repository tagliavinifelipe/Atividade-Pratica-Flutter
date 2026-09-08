import 'package:flutter_test/flutter_test.dart';
import 'package:app_catalogo_mobile/main.dart';

void main() {
  testWidgets('Exibe o nome do produto na tela', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());
    expect(find.text('Smartphone Galaxy S24'), findsOneWidget);
  });
}