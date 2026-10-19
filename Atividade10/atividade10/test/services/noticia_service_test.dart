import 'dart:convert';

import 'package:atividade10/services/noticia_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NoticiaService.buscarNoticias', () {
    test('retorna os modelos quando o status e 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'id': 1, 'userId': 1, 'title': 'A', 'body': 'Corpo A'},
            {'id': 2, 'userId': 1, 'title': 'B', 'body': 'Corpo B'},
          ]),
          200,
        );
      });

      final noticias = await NoticiaService(client: client).buscarNoticias();

      expect(noticias, hasLength(2));
      expect(noticias.first.titulo, 'A');
      expect(noticias.last.id, 2);
    });

    test('lanca excecao de status quando o servidor responde 500', () async {
      final client = MockClient((request) async => http.Response('', 500));

      await expectLater(
        NoticiaService(client: client).buscarNoticias(),
        throwsA(
          predicate((e) => e.toString().contains('Status HTTP de erro: 500')),
        ),
      );
    });

    test('lanca excecao de conexao quando o client falha', () async {
      final client = MockClient((request) async {
        throw http.ClientException('sem rede');
      });

      await expectLater(
        NoticiaService(client: client).buscarNoticias(),
        throwsA(
          predicate(
            (e) => e.toString().contains('Falha ao conectar com a API'),
          ),
        ),
      );
    });

    test('usa a URL inexistente quando simularErro e true', () async {
      Uri? urlChamada;
      final client = MockClient((request) async {
        urlChamada = request.url;
        return http.Response('[]', 200);
      });

      await NoticiaService(client: client).buscarNoticias(simularErro: true);

      expect(urlChamada?.host, 'api-inexistente.invalid');
    });
  });
}
