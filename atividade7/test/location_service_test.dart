import 'dart:async';

import 'package:atividade7/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Substitui a parte nativa do geolocator: assim o LocationService REAL
/// é testado sem celular nem emulador.
class FakeGeolocatorPlatform extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  bool servicoHabilitado = true;
  LocationPermission permissaoAtual = LocationPermission.whileInUse;
  LocationPermission respostaDoUsuario = LocationPermission.whileInUse;
  int pedidosDePermissao = 0;
  LocationSettings? configuracaoUsada;
  final StreamController<Position> stream = StreamController<Position>();

  @override
  Future<bool> isLocationServiceEnabled() async => servicoHabilitado;

  @override
  Future<LocationPermission> checkPermission() async => permissaoAtual;

  @override
  Future<LocationPermission> requestPermission() async {
    pedidosDePermissao++;
    permissaoAtual = respostaDoUsuario;
    return respostaDoUsuario;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    configuracaoUsada = locationSettings;
    return posicaoFatec;
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    configuracaoUsada = locationSettings;
    return stream.stream;
  }
}

final Position posicaoFatec = Position(
  latitude: -21.6176956,
  longitude: -48.3601206,
  timestamp: DateTime(2026, 11, 22),
  accuracy: 8,
  altitude: 560,
  altitudeAccuracy: 1,
  heading: 0,
  headingAccuracy: 1,
  speed: 0,
  speedAccuracy: 0,
);

Matcher _excecaoCom(String mensagem) => isA<Exception>().having(
  (Exception e) => e.toString(),
  'mensagem',
  'Exception: $mensagem',
);

void main() {
  late FakeGeolocatorPlatform plataforma;
  final LocationService service = LocationService();

  setUp(() {
    plataforma = FakeGeolocatorPlatform();
    GeolocatorPlatform.instance = plataforma;
  });

  group('obterPosicaoAtual', () {
    test('GPS desligado lança a exceção do serviço desativado', () async {
      plataforma.servicoHabilitado = false;

      await expectLater(
        service.obterPosicaoAtual(),
        throwsA(
          _excecaoCom('O serviço de GPS está desativado no dispositivo.'),
        ),
      );
      expect(plataforma.pedidosDePermissao, 0);
    });

    test('permissão negada no diálogo lança a exceção de negada', () async {
      plataforma.permissaoAtual = LocationPermission.denied;
      plataforma.respostaDoUsuario = LocationPermission.denied;

      await expectLater(
        service.obterPosicaoAtual(),
        throwsA(_excecaoCom('Permissão de localização negada pelo usuário.')),
      );
      expect(plataforma.pedidosDePermissao, 1);
    });

    test('permissão negada permanentemente não pede de novo', () async {
      plataforma.permissaoAtual = LocationPermission.deniedForever;

      await expectLater(
        service.obterPosicaoAtual(),
        throwsA(
          _excecaoCom(
            'Permissões negadas permanentemente. Altere nas configurações.',
          ),
        ),
      );
      expect(plataforma.pedidosDePermissao, 0);
    });

    test('usuário aceita o diálogo e recebe a posição', () async {
      plataforma.permissaoAtual = LocationPermission.denied;
      plataforma.respostaDoUsuario = LocationPermission.whileInUse;

      final Position posicao = await service.obterPosicaoAtual();

      expect(plataforma.pedidosDePermissao, 1);
      expect(posicao.latitude, -21.6176956);
      expect(posicao.longitude, -48.3601206);
      expect(plataforma.configuracaoUsada?.accuracy, LocationAccuracy.high);
    });

    test('permissão já concedida retorna a posição sem pedir', () async {
      plataforma.permissaoAtual = LocationPermission.always;

      final Position posicao = await service.obterPosicaoAtual();

      expect(plataforma.pedidosDePermissao, 0);
      expect(posicao.accuracy, 8);
    });
  });

  test('monitorarPosicao usa alta precisão, filtro de 10 m e repassa '
      'as posições', () async {
    final Stream<Position> fluxo = service.monitorarPosicao();

    expect(plataforma.configuracaoUsada?.accuracy, LocationAccuracy.high);
    expect(plataforma.configuracaoUsada?.distanceFilter, 10);

    final Future<Position> primeira = fluxo.first;
    plataforma.stream.add(posicaoFatec);
    expect((await primeira).latitude, -21.6176956);
  });
}
