import 'package:atividade7/utils/distancia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatarDistancia', () {
    test('999 m é exibido em metros', () {
      expect(formatarDistancia(999), '999 m');
    });

    test('1000 m é exibido em km', () {
      expect(formatarDistancia(1000), '1,00 km');
    });

    test('3420 m é exibido em km com vírgula', () {
      expect(formatarDistancia(3420), '3,42 km');
    });
  });
}
