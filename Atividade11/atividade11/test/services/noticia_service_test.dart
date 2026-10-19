import 'dart:convert';

import 'package:atividade11/services/noticia_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Matcher _excecaoCom(String trecho) =>
    throwsA(predicate((e) => e.toString().contains(trecho)));

void main() {
  group('NoticiaService.buscarNoticias', () {
    test('retorna os modelos quando o status e 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'id': 1, 'userId': 1, 'title': 'A', 'body': 'Corpo A'},
            {'id': 2, 'userId': 2, 'title': 'B', 'body': 'Corpo B'},
          ]),
          200,
        );
      });

      final noticias = await NoticiaService(client: client).buscarNoticias();

      expect(noticias, hasLength(2));
      expect(noticias.last.autor, 'Autor ID 2');
    });

    test('lanca excecao de status quando o servidor responde 404', () async {
      final client = MockClient((request) async => http.Response('', 404));

      await expectLater(
        NoticiaService(client: client).buscarNoticias(),
        _excecaoCom('Status HTTP de erro: 404'),
      );
    });

    test('lanca excecao de conexao quando o client falha', () async {
      final client = MockClient((request) async {
        throw http.ClientException('sem rede');
      });

      await expectLater(
        NoticiaService(client: client).buscarNoticias(),
        _excecaoCom('Falha ao conectar com a API'),
      );
    });
  });

  group('NoticiaService.buscarComentarios', () {
    test('retorna os comentarios e chama /posts/1/comments', () async {
      Uri? urlChamada;
      final client = MockClient((request) async {
        urlChamada = request.url;
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'postId': 1,
              'name': 'Ana',
              'email': 'ana@exemplo.com',
              'body': 'Comentario',
            },
          ]),
          200,
        );
      });

      final comentarios = await NoticiaService(client: client)
          .buscarComentarios(1);

      expect(comentarios, hasLength(1));
      expect(comentarios.first.nome, 'Ana');
      expect(urlChamada.toString(), endsWith('/posts/1/comments'));
    });

    test('lanca excecao de status quando o servidor responde 500', () async {
      final client = MockClient((request) async => http.Response('', 500));

      await expectLater(
        NoticiaService(client: client).buscarComentarios(1),
        _excecaoCom('Status HTTP de erro: 500'),
      );
    });
  });
}
