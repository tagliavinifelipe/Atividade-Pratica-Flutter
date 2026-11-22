import 'dart:io';

import 'package:aula15/services/perfil_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Substitui a parte nativa do path_provider apontando para uma pasta temporária.
class FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  FakePathProvider(this.documentos);

  final String documentos;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentos;
}

void main() {
  late Directory diretorioTemporario;
  late PerfilStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    diretorioTemporario = await Directory.systemTemp.createTemp('perfil_');
    storage = PerfilStorage(
      diretorioDocumentos: () async => diretorioTemporario,
    );
  });

  tearDown(() async {
    if (await diretorioTemporario.exists()) {
      await diretorioTemporario.delete(recursive: true);
    }
  });

  test('salva, lê e remove o caminho da foto', () async {
    expect(await storage.lerCaminho(), isNull);

    await storage.salvarCaminho('/fotos/perfil.jpg');
    expect(await storage.lerCaminho(), '/fotos/perfil.jpg');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PerfilStorage.chaveFotoPerfil), '/fotos/perfil.jpg');

    await storage.removerCaminho();
    expect(await storage.lerCaminho(), isNull);
  });

  test('carregarFoto limpa a chave quando o arquivo não existe mais', () async {
    await storage.salvarCaminho(
      '${diretorioTemporario.path}${Platform.pathSeparator}inexistente.jpg',
    );

    expect(await storage.carregarFoto(), isNull);
    expect(await storage.lerCaminho(), isNull);
  });

  test(
    'salvarFoto copia o arquivo para documentos e permite carregar',
    () async {
      final File origem = File(
        '${diretorioTemporario.path}${Platform.pathSeparator}origem.jpg',
      );
      await origem.writeAsBytes(<int>[1, 2, 3]);

      final File copia = await storage.salvarFoto(origem);

      expect(copia.path, isNot(origem.path));
      expect(await copia.exists(), isTrue);
      expect(await storage.lerCaminho(), copia.path);

      final File? carregada = await storage.carregarFoto();
      expect(carregada?.path, copia.path);

      await storage.removerFoto();
      expect(await storage.lerCaminho(), isNull);
      expect(await copia.exists(), isFalse);
    },
  );

  test(
    'construtor padrão copia para getApplicationDocumentsDirectory',
    () async {
      final Directory documentos = Directory(
        '${diretorioTemporario.path}${Platform.pathSeparator}documentos',
      )..createSync();
      PathProviderPlatform.instance = FakePathProvider(documentos.path);
      final File origem = File(
        '${diretorioTemporario.path}${Platform.pathSeparator}cache.jpg',
      )..writeAsBytesSync(<int>[1, 2, 3]);

      final File copia = await PerfilStorage().salvarFoto(origem);

      expect(copia.parent.path, documentos.path);
      expect(copia.readAsBytesSync(), <int>[1, 2, 3]);
      expect(copia.path, endsWith('.jpg'));
    },
  );

  test('foto continua salva ao "reabrir o app", mesmo sem o cache', () async {
    final File origem = File(
      '${diretorioTemporario.path}${Platform.pathSeparator}cache.jpg',
    )..writeAsBytesSync(<int>[9]);
    final File copia = await storage.salvarFoto(origem);

    // O sistema pode limpar o cache do image_picker a qualquer momento.
    await origem.delete();

    // Nova instância = app fechado e aberto de novo.
    final PerfilStorage reaberto = PerfilStorage(
      diretorioDocumentos: () async => diretorioTemporario,
    );
    final File? carregada = await reaberto.carregarFoto();

    expect(carregada?.path, copia.path);
    expect(await carregada!.exists(), isTrue);
  });

  test('trocar de foto apaga a cópia anterior', () async {
    final File origem = File(
      '${diretorioTemporario.path}${Platform.pathSeparator}cache.jpg',
    )..writeAsBytesSync(<int>[1]);

    final File primeira = await storage.salvarFoto(origem);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final File segunda = await storage.salvarFoto(origem);

    expect(segunda.path, isNot(primeira.path));
    expect(await primeira.exists(), isFalse);
    expect(await segunda.exists(), isTrue);
    expect(await storage.lerCaminho(), segunda.path);
  });
}
