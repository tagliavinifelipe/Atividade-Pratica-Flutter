import 'dart:async';

import 'package:atividade7/main.dart';
import 'package:atividade7/screens/geolocalizacao_screen.dart';
import 'package:atividade7/services/location_service.dart';
import 'package:atividade7/utils/constantes.dart';
import 'package:atividade7/utils/distancia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class FakeLocationService extends LocationService {
  FakeLocationService({this.posicao, this.erro});

  final Position? posicao;
  final Exception? erro;
  Completer<void>? atraso;
  final StreamController<Position> fluxo = StreamController<Position>();

  @override
  Future<Position> obterPosicaoAtual() async {
    if (atraso != null) await atraso!.future;
    if (erro != null) throw erro!;
    return posicao!;
  }

  @override
  Stream<Position> monitorarPosicao() => fluxo.stream;
}

/// Substitui a parte nativa do url_launcher para conferir o link aberto.
class FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  FakeUrlLauncher({this.consegueAbrir = true});

  final bool consegueAbrir;
  String? urlAberta;
  PreferredLaunchMode? modo;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urlAberta = url;
    modo = options.mode;
    return consegueAbrir;
  }
}

Position _posicao({
  double latitude = -21.603,
  double longitude = -48.366,
  double precisao = 10,
}) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime(2026, 11, 22),
    accuracy: precisao,
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

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('app abre com título, botões e sem coordenadas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MeuApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Aula 14 - GPS');
    expect(find.text('Check-in & GPS'), findsOneWidget);
    expect(find.text('Capturar Localização Atual'), findsOneWidget);
    expect(find.text('Iniciar Rastreamento Contínuo'), findsOneWidget);
    expect(find.text('Latitude'), findsNothing);
    expect(find.text('Abrir no Mapa'), findsNothing);
  });

  testWidgets('mostra carregando e depois coordenadas, precisão e distância', (
    WidgetTester tester,
  ) async {
    final Position posicao = _posicao();
    final FakeLocationService service = FakeLocationService(posicao: posicao)
      ..atraso = Completer<void>();
    await _abrirTela(tester, service);

    await tester.tap(find.text('Capturar Localização Atual'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final ElevatedButton botao = tester.widget(
      find.widgetWithText(ElevatedButton, 'Capturar Localização Atual'),
    );
    expect(botao.onPressed, isNull, reason: 'botão desabilitado ao carregar');

    service.atraso!.complete();
    await tester.pumpAndSettle();

    final String distanciaEsperada = formatarDistancia(
      Geolocator.distanceBetween(
        posicao.latitude,
        posicao.longitude,
        kLatitudeFatec,
        kLongitudeFatec,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Latitude'), findsOneWidget);
    expect(find.text('-21.603'), findsOneWidget);
    expect(find.text('Longitude'), findsOneWidget);
    expect(find.text('-48.366'), findsOneWidget);
    expect(find.text('Precisão / Altitude'), findsOneWidget);
    expect(find.text('Precisão: 10.0m | Alt: 550.0m'), findsOneWidget);
    expect(find.byType(Chip), findsOneWidget);
    expect(find.text('Precisão alta (10.0 m)'), findsOneWidget);
    expect(find.text('Distância até a Fatec Matão'), findsOneWidget);
    expect(find.text(distanciaEsperada), findsOneWidget);
    expect(distanciaEsperada, endsWith(' km'));
    expect(find.text('Abrir no Mapa'), findsOneWidget);
  });

  testWidgets('na própria Fatec a distância aparece em metros', (
    WidgetTester tester,
  ) async {
    await _abrirTela(
      tester,
      FakeLocationService(
        posicao: _posicao(latitude: kLatitudeFatec, longitude: kLongitudeFatec),
      ),
    );

    await _tocar(tester, 'Capturar Localização Atual');

    expect(find.text('0 m'), findsOneWidget);
  });

  for (final (double precisao, String rotulo) in [
    (10.0, 'Precisão alta (10.0 m)'),
    (30.0, 'Precisão média (30.0 m)'),
    (80.0, 'Precisão baixa (80.0 m)'),
  ]) {
    testWidgets('Chip mostra "$rotulo"', (WidgetTester tester) async {
      await _abrirTela(
        tester,
        FakeLocationService(posicao: _posicao(precisao: precisao)),
      );

      await _tocar(tester, 'Capturar Localização Atual');

      expect(find.text(rotulo), findsOneWidget);
    });
  }

  for (final String mensagem in [
    'O serviço de GPS está desativado no dispositivo.',
    'Permissão de localização negada pelo usuário.',
    'Permissões negadas permanentemente. Altere nas configurações.',
  ]) {
    testWidgets('erro "$mensagem" aparece sem o prefixo "Exception: "', (
      WidgetTester tester,
    ) async {
      await _abrirTela(tester, FakeLocationService(erro: Exception(mensagem)));

      await _tocar(tester, 'Capturar Localização Atual');

      expect(find.text(mensagem), findsOneWidget);
      expect(find.textContaining('Exception'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('rastreamento contínuo atualiza a posição e pode ser parado', (
    WidgetTester tester,
  ) async {
    final FakeLocationService service = FakeLocationService();
    await _abrirTela(tester, service);

    await _tocar(tester, 'Iniciar Rastreamento Contínuo');
    expect(find.text('Parar Rastreamento'), findsOneWidget);
    expect(service.fluxo.hasListener, isTrue);

    service.fluxo.add(_posicao(latitude: -21.1, longitude: -48.1));
    await tester.pumpAndSettle();
    expect(find.text('-21.1'), findsOneWidget);

    service.fluxo.add(_posicao(latitude: -21.2, longitude: -48.2));
    await tester.pumpAndSettle();
    expect(find.text('-21.2'), findsOneWidget);
    expect(find.text('-21.1'), findsNothing);

    await _tocar(tester, 'Parar Rastreamento');
    expect(find.text('Iniciar Rastreamento Contínuo'), findsOneWidget);
    expect(service.fluxo.hasListener, isFalse);
  });

  testWidgets('erro no rastreamento destrava o botão e mostra a mensagem', (
    WidgetTester tester,
  ) async {
    final FakeLocationService service = FakeLocationService();
    await _abrirTela(tester, service);

    await _tocar(tester, 'Iniciar Rastreamento Contínuo');
    service.fluxo.addError(Exception('Sinal de GPS perdido.'));
    await tester.pumpAndSettle();

    expect(find.text('Sinal de GPS perdido.'), findsOneWidget);
    expect(find.text('Iniciar Rastreamento Contínuo'), findsOneWidget);
    expect(find.text('Parar Rastreamento'), findsNothing);
    expect(service.fluxo.hasListener, isFalse);
  });

  testWidgets('sair da tela cancela o rastreamento (dispose)', (
    WidgetTester tester,
  ) async {
    final FakeLocationService service = FakeLocationService();
    await _abrirTela(tester, service);
    await _tocar(tester, 'Iniciar Rastreamento Contínuo');
    expect(service.fluxo.hasListener, isTrue);

    await tester.pumpWidget(const SizedBox());

    expect(service.fluxo.hasListener, isFalse);
  });

  testWidgets('"Abrir no Mapa" abre o Google Maps fora do app', (
    WidgetTester tester,
  ) async {
    final FakeUrlLauncher launcher = FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
    await _abrirTela(tester, FakeLocationService(posicao: _posicao()));

    await _tocar(tester, 'Capturar Localização Atual');
    await _tocar(tester, 'Abrir no Mapa');

    expect(launcher.urlAberta, 'https://maps.google.com/?q=-21.603,-48.366');
    expect(launcher.modo, PreferredLaunchMode.externalApplication);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('se o mapa não abrir, mostra um SnackBar', (
    WidgetTester tester,
  ) async {
    UrlLauncherPlatform.instance = FakeUrlLauncher(consegueAbrir: false);
    await _abrirTela(tester, FakeLocationService(posicao: _posicao()));

    await _tocar(tester, 'Capturar Localização Atual');
    await _tocar(tester, 'Abrir no Mapa');

    expect(
      find.text('Não foi possível abrir o mapa neste dispositivo.'),
      findsOneWidget,
    );
  });
}
