import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/noticia_model.dart';

class NoticiaService {
  static const String _urlBase = 'https://jsonplaceholder.typicode.com/posts';
  static const String _urlInexistente = 'https://api-inexistente.invalid/posts';

  final http.Client _client;

  NoticiaService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<NoticiaModel>> buscarNoticias({bool simularErro = false}) async {
    final url = simularErro ? _urlInexistente : _urlBase;
    final http.Response response;

    // Erros de rede (sem conexao, DNS, timeout) sao tratados aqui.
    try {
      response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception('Falha ao conectar com a API: $e');
    }

    // Erro de status fica fora do catch para nao ser reembrulhado acima.
    if (response.statusCode != 200) {
      throw Exception('Status HTTP de erro: ${response.statusCode}');
    }

    final List<dynamic> dados = jsonDecode(response.body);
    return dados
        .map((json) => NoticiaModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
