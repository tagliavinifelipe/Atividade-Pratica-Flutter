import 'package:atividade7/screens/geolocalizacao_screen.dart';
import 'package:atividade7/services/location_service.dart';
import 'package:atividade7/utils/constantes.dart';
import 'package:atividade7/utils/distancia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class FakeLocationService extends LocationService {
  FakeLocationService({this.posicao, this.erro});

  final Position? posicao;
  final Exception? erro;

  @override
  Future<Position> obterPosicaoAtual() async {
    if (erro != null) throw erro!;
    return posicao!;
  }

  @override
  Stream<Position> monitorarPosicao() => const Stream<Position>.empty();
}

Position _posicaoFake() {
  return Position(
    latitude: -21.603,
    longitude: -48.366,
    timestamp: DateTime(2026, 11, 22),
    accuracy: 10,
    altitude: 550,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 0,
  );
}

Future<void> _abrirTela(WidgetTester tester, LocationService service) {
  return tester.pumpWidget(
    MaterialApp(home: GeolocalizacaoScreen(locationService: service)),
  );
}

Future<void> _tocarCapturar(WidgetTester tester) async {
  final Finder botao = find.text('Capturar Localização Atual');
  await tester.ensureVisible(botao);
  await tester.tap(botao);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra coordenadas, precisão e distância após capturar', (
    WidgetTester tester,
  ) async {
    final Position posicao = _posicaoFake();
    await _abrirTela(tester, FakeLocationService(posicao: posicao));

    expect(find.byType(Chip), findsNothing);
    expect(find.text('Abrir no Mapa'), findsNothing);

    await _tocarCapturar(tester);

    final String distanciaEsperada = formatarDistancia(
      Geolocator.distanceBetween(
        posicao.latitude,
        posicao.longitude,
        kLatitudeFatec,
        kLongitudeFatec,
      ),
    );

    expect(find.text('-21.603'), findsOneWidget);
    expect(find.text('-48.366'), findsOneWidget);
    expect(find.byType(Chip), findsOneWidget);
    expect(find.text('Precisão alta (10.0 m)'), findsOneWidget);
    expect(find.text('Distância até a Fatec Matão'), findsOneWidget);
    expect(find.text(distanciaEsperada), findsOneWidget);
    expect(find.text('Abrir no Mapa'), findsOneWidget);
  });

  testWidgets('mostra a mensagem de erro sem o prefixo "Exception: "', (
    WidgetTester tester,
  ) async {
    await _abrirTela(
      tester,
      FakeLocationService(
        erro: Exception('O serviço de GPS está desativado no dispositivo.'),
      ),
    );

    await _tocarCapturar(tester);

    expect(
      find.text('O serviço de GPS está desativado no dispositivo.'),
      findsOneWidget,
    );
    expect(find.textContaining('Exception'), findsNothing);
  });
}
