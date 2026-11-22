import 'dart:io';

import 'package:aula15/services/perfil_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
