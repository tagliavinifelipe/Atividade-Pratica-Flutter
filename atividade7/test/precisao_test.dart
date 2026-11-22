import 'package:atividade7/utils/precisao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classificarPrecisao', () {
    test('14.9 m é precisão alta (verde)', () {
      expect(classificarPrecisao(14.9), NivelPrecisao.alta);
    });

    test('15 m é precisão média (amarelo)', () {
      expect(classificarPrecisao(15), NivelPrecisao.media);
    });

    test('50 m é precisão média (amarelo)', () {
      expect(classificarPrecisao(50), NivelPrecisao.media);
    });

    test('50.1 m é precisão baixa (vermelho)', () {
      expect(classificarPrecisao(50.1), NivelPrecisao.baixa);
    });
  });
}
