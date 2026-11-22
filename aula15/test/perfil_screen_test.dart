import 'dart:convert';
import 'dart:io';

import 'package:aula15/main.dart';
import 'package:aula15/screens/foto_tela_cheia_screen.dart';
import 'package:aula15/screens/perfil_screen.dart';
import 'package:aula15/services/media_service.dart';
import 'package:aula15/services/perfil_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PNG válido de 1x1 pixel, para as fotos de teste serem imagens de verdade.
final List<int> _png1x1 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class FakeMediaService extends MediaService {
  FakeMediaService({this.fotoCamera, this.fotoGaleria, this.falhar = false});

  final File? fotoCamera;
  final File? fotoGaleria;
  final bool falhar;
  final List<String> chamadas = <String>[];

  @override
  Future<File?> tirarFoto() async {
    chamadas.add('camera');
    if (falhar) throw Exception('câmera indisponível');
    return fotoCamera;
  }

  @override
  Future<File?> selecionarDaGaleria() async {
    chamadas.add('galeria');
    if (falhar) throw Exception('galeria indisponível');
    return fotoGaleria;
  }
}

/// Guarda tudo em memória: simula a foto salva entre aberturas do app.
class FakePerfilStorage extends PerfilStorage {
  FakePerfilStorage({this.fotoSalva, required this.fotoCopiada});

  File? fotoSalva;
  final File fotoCopiada;
  File? origemRecebida;
  int remocoes = 0;

  @override
  Future<File?> carregarFoto() async => fotoSalva;

  @override
  Future<File> salvarFoto(File origem) async {
    origemRecebida = origem;
    fotoSalva = fotoCopiada;
    return fotoCopiada;
  }

  @override
  Future<void> removerFoto() async {
    remocoes++;
    fotoSalva = null;
  }
}

void main() {
  late Directory pasta;
  late File fotoCamera;
  late File fotoGaleria;
  late File fotoCopiada;

  setUpAll(() async {
    pasta = await Directory.systemTemp.createTemp('perfil_tela_');
    fotoCamera = File('${pasta.path}/camera.png')..writeAsBytesSync(_png1x1);
    fotoGaleria = File('${pasta.path}/galeria.png')..writeAsBytesSync(_png1x1);
    fotoCopiada = File('${pasta.path}/copia.png')..writeAsBytesSync(_png1x1);
  });

  tearDownAll(() async {
    await pasta.delete(recursive: true);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> abrirTela(
    WidgetTester tester, {
    required MediaService media,
    required PerfilStorage storage,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilScreen(mediaService: media, perfilStorage: storage),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  String? caminhoDoAvatar(WidgetTester tester) {
    final CircleAvatar avatar = tester.widget(find.byType(CircleAvatar));
    final ImageProvider? imagem = avatar.backgroundImage;
    return imagem is FileImage ? imagem.file.path : null;
  }

  testWidgets('app abre com título, nome padrão e avatar sem foto', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MeuApp());
    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Aula 15 - Câmera e Mídia');
    expect(find.text('Perfil do Usuário'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nome Completo'), findsOneWidget);
    expect(find.text('Diego Menegassi'), findsOneWidget);
  });

  testWidgets('bottom sheet mostra câmera e galeria, sem "Remover Foto"', (
    WidgetTester tester,
  ) async {
    await abrirTela(
      tester,
      media: FakeMediaService(),
      storage: FakePerfilStorage(fotoCopiada: fotoCopiada),
    );

    await tocar(tester, find.byType(FloatingActionButton));

    expect(find.text('Tirar Foto com a Câmera'), findsOneWidget);
    expect(find.text('Escolher da Galeria'), findsOneWidget);
    expect(find.text('Remover Foto'), findsNothing);
  });

  testWidgets('tirar foto mostra a foto no avatar e salva a cópia', (
    WidgetTester tester,
  ) async {
    final FakeMediaService media = FakeMediaService(fotoCamera: fotoCamera);
    final FakePerfilStorage storage = FakePerfilStorage(
      fotoCopiada: fotoCopiada,
    );
    await abrirTela(tester, media: media, storage: storage);

    await tocar(tester, find.byType(FloatingActionButton));
    await tocar(tester, find.text('Tirar Foto com a Câmera'));

    expect(media.chamadas, ['camera']);
    expect(storage.origemRecebida?.path, fotoCamera.path);
    expect(caminhoDoAvatar(tester), fotoCopiada.path);
    expect(find.byIcon(Icons.person), findsNothing);
    expect(find.text('Tirar Foto com a Câmera'), findsNothing);
  });

  testWidgets('escolher da galeria mostra a foto no avatar', (
    WidgetTester tester,
  ) async {
    final FakeMediaService media = FakeMediaService(fotoGaleria: fotoGaleria);
    final FakePerfilStorage storage = FakePerfilStorage(
      fotoCopiada: fotoCopiada,
    );
    await abrirTela(tester, media: media, storage: storage);

    await tocar(tester, find.byType(FloatingActionButton));
    await tocar(tester, find.text('Escolher da Galeria'));

    expect(media.chamadas, ['galeria']);
    expect(storage.origemRecebida?.path, fotoGaleria.path);
    expect(caminhoDoAvatar(tester), fotoCopiada.path);
  });

  testWidgets('cancelar a escolha mantém o avatar sem foto', (
    WidgetTester tester,
  ) async {
    final FakePerfilStorage storage = FakePerfilStorage(
      fotoCopiada: fotoCopiada,
    );
    await abrirTela(tester, media: FakeMediaService(), storage: storage);

    await tocar(tester, find.byType(FloatingActionButton));
    await tocar(tester, find.text('Escolher da Galeria'));

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(storage.origemRecebida, isNull);
  });

  testWidgets('falha da câmera mostra um SnackBar', (
    WidgetTester tester,
  ) async {
    await abrirTela(
      tester,
      media: FakeMediaService(falhar: true),
      storage: FakePerfilStorage(fotoCopiada: fotoCopiada),
    );

    await tocar(tester, find.byType(FloatingActionButton));
    await tocar(tester, find.text('Tirar Foto com a Câmera'));

    expect(find.text('Não foi possível obter a imagem.'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('foto salva aparece ao abrir o app (persistência)', (
    WidgetTester tester,
  ) async {
    await abrirTela(
      tester,
      media: FakeMediaService(),
      storage: FakePerfilStorage(
        fotoSalva: fotoCopiada,
        fotoCopiada: fotoCopiada,
      ),
    );

    expect(caminhoDoAvatar(tester), fotoCopiada.path);
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets('"Remover Foto" aparece com foto e volta para o ícone', (
    WidgetTester tester,
  ) async {
    final FakePerfilStorage storage = FakePerfilStorage(
      fotoSalva: fotoCopiada,
      fotoCopiada: fotoCopiada,
    );
    await abrirTela(tester, media: FakeMediaService(), storage: storage);

    await tocar(tester, find.byType(FloatingActionButton));
    expect(find.text('Remover Foto'), findsOneWidget);

    await tocar(tester, find.text('Remover Foto'));

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(caminhoDoAvatar(tester), isNull);
    expect(storage.remocoes, 1);
    expect(storage.fotoSalva, isNull);
  });

  testWidgets('tocar no avatar sem foto não abre a tela cheia', (
    WidgetTester tester,
  ) async {
    await abrirTela(
      tester,
      media: FakeMediaService(),
      storage: FakePerfilStorage(fotoCopiada: fotoCopiada),
    );

    await tocar(tester, find.byType(CircleAvatar));

    expect(find.byType(FotoTelaCheiaScreen), findsNothing);
  });

  testWidgets('tocar no avatar com foto abre tela cheia com Hero e zoom', (
    WidgetTester tester,
  ) async {
    await abrirTela(
      tester,
      media: FakeMediaService(),
      storage: FakePerfilStorage(
        fotoSalva: fotoCopiada,
        fotoCopiada: fotoCopiada,
      ),
    );

    // O FloatingActionButton também tem um Hero; pegamos o do avatar.
    final Hero heroAvatar = tester.widget(
      find.ancestor(of: find.byType(CircleAvatar), matching: find.byType(Hero)),
    );
    await tocar(tester, find.byType(CircleAvatar));

    expect(find.byType(FotoTelaCheiaScreen), findsOneWidget);

    final Hero heroTelaCheia = tester.widget(
      find.descendant(
        of: find.byType(FotoTelaCheiaScreen),
        matching: find.byType(Hero),
      ),
    );
    expect(heroTelaCheia.tag, heroAvatar.tag);

    final InteractiveViewer zoom = tester.widget(
      find.byType(InteractiveViewer),
    );
    expect(zoom.minScale, 1);
    expect(zoom.maxScale, 4);

    final Image imagem = tester.widget(
      find.descendant(
        of: find.byType(InteractiveViewer),
        matching: find.byType(Image),
      ),
    );
    expect((imagem.image as FileImage).file.path, fotoCopiada.path);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Perfil do Usuário'), findsOneWidget);
  });
}
