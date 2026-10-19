import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/comentario_model.dart';
import '../models/noticia_model.dart';

class NoticiaService {
  static const String urlBase = 'https://jsonplaceholder.typicode.com/posts';

  final http.Client _client;

  NoticiaService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<NoticiaModel>> buscarNoticias() async {
    final List<dynamic> dados = await _buscarLista(Uri.parse(urlBase));
    return dados
        .map((json) => NoticiaModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ComentarioModel>> buscarComentarios(int noticiaId) async {
    final List<dynamic> dados = await _buscarLista(
      Uri.parse('$urlBase/$noticiaId/comments'),
    );
    return dados
        .map((json) => ComentarioModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> _buscarLista(Uri url) async {
    final http.Response response;

    // Erros de rede (sem conexao, DNS, timeout) sao tratados aqui.
    try {
      response = await _client.get(url).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception('Falha ao conectar com a API: $e');
    }

    // Erro de status fica fora do catch para nao ser reembrulhado acima.
    if (response.statusCode != 200) {
      throw Exception('Status HTTP de erro: ${response.statusCode}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }
}
