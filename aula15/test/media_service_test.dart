import 'dart:io';

import 'package:aula15/services/media_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Substitui a parte nativa do image_picker: assim o MediaService REAL
/// é testado sem câmera nem emulador.
class FakeImagePickerPlatform extends ImagePickerPlatform
    with MockPlatformInterfaceMixin {
  FakeImagePickerPlatform(this.caminhoRetornado);

  final String? caminhoRetornado;
  ImageSource? origemPedida;
  ImagePickerOptions? opcoesPedidas;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    origemPedida = source;
    opcoesPedidas = options;
    final String? caminho = caminhoRetornado;
    return caminho == null ? null : XFile(caminho);
  }
}

void main() {
  final MediaService service = MediaService();

  test('tirarFoto usa a câmera com qualidade 85 e largura 1080', () async {
    final FakeImagePickerPlatform plataforma = FakeImagePickerPlatform(
      '/cache/foto_camera.jpg',
    );
    ImagePickerPlatform.instance = plataforma;

    final File? foto = await service.tirarFoto();

    expect(plataforma.origemPedida, ImageSource.camera);
    expect(plataforma.opcoesPedidas?.imageQuality, 85);
    expect(plataforma.opcoesPedidas?.maxWidth, 1080);
    expect(foto?.path, '/cache/foto_camera.jpg');
  });

  test(
    'selecionarDaGaleria usa a galeria com qualidade 85 e largura 1080',
    () async {
      final FakeImagePickerPlatform plataforma = FakeImagePickerPlatform(
        '/cache/foto_galeria.png',
      );
      ImagePickerPlatform.instance = plataforma;

      final File? foto = await service.selecionarDaGaleria();

      expect(plataforma.origemPedida, ImageSource.gallery);
      expect(plataforma.opcoesPedidas?.imageQuality, 85);
      expect(plataforma.opcoesPedidas?.maxWidth, 1080);
      expect(foto?.path, '/cache/foto_galeria.png');
    },
  );

  test('retorna null quando o usuário cancela', () async {
    ImagePickerPlatform.instance = FakeImagePickerPlatform(null);

    expect(await service.tirarFoto(), isNull);
    expect(await service.selecionarDaGaleria(), isNull);
  });
}
