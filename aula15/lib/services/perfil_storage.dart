import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda a foto de perfil no diretório de documentos do app e salva o
/// caminho dela no SharedPreferences, para que ela sobreviva ao fechar o app.
class PerfilStorage {
  PerfilStorage({Future<Directory> Function()? diretorioDocumentos})
    : _diretorioDocumentos =
          diretorioDocumentos ?? getApplicationDocumentsDirectory;

  static const String chaveFotoPerfil = 'foto_perfil_path';

  final Future<Directory> Function() _diretorioDocumentos;

  Future<void> salvarCaminho(String caminho) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(chaveFotoPerfil, caminho);
  }

  Future<String?> lerCaminho() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(chaveFotoPerfil);
  }

  Future<void> removerCaminho() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(chaveFotoPerfil);
  }

  /// Copia a imagem escolhida (que o image_picker deixa no cache) para o
  /// diretório de documentos e salva o novo caminho.
  Future<File> salvarFoto(File origem) async {
    final Directory diretorio = await _diretorioDocumentos();
    final String caminhoAnterior = await lerCaminho() ?? '';

    final int ponto = origem.path.lastIndexOf('.');
    final String extensao = ponto >= 0 ? origem.path.substring(ponto) : '.jpg';
    // Nome único a cada foto, para o cache de imagens do Flutter não
    // reaproveitar a foto anterior.
    final String nomeArquivo =
        'foto_perfil_${DateTime.now().millisecondsSinceEpoch}$extensao';

    final File copia = await origem.copy(
      '${diretorio.path}${Platform.pathSeparator}$nomeArquivo',
    );
    await salvarCaminho(copia.path);

    if (caminhoAnterior.isNotEmpty && caminhoAnterior != copia.path) {
      await _apagarArquivo(caminhoAnterior);
    }
    return copia;
  }

  /// Retorna a foto salva se o arquivo ainda existir; caso contrário,
  /// limpa a chave e retorna null.
  Future<File?> carregarFoto() async {
    final String? caminho = await lerCaminho();
    if (caminho == null) return null;

    final File arquivo = File(caminho);
    if (await arquivo.exists()) return arquivo;

    await removerCaminho();
    return null;
  }

  /// Remove o caminho salvo e apaga a cópia da foto.
  Future<void> removerFoto() async {
    final String? caminho = await lerCaminho();
    await removerCaminho();
    if (caminho != null) {
      await _apagarArquivo(caminho);
    }
  }

  Future<void> _apagarArquivo(String caminho) async {
    final File arquivo = File(caminho);
    try {
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
    } on FileSystemException {
      // Se não der para apagar, o arquivo apenas fica órfão no diretório.
    }
  }
}
