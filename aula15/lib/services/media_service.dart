import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  // Captura foto da câmera
  Future<File?> tirarFoto() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (foto != null) return File(foto.path);
    return null;
  }

  // Seleciona foto da galeria
  Future<File?> selecionarDaGaleria() async {
    final XFile? imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (imagem != null) return File(imagem.path);
    return null;
  }
}
