import 'dart:async';
import 'dart:convert';

import 'package:atividade11/models/noticia_model.dart';
import 'package:atividade11/screens/detalhe_noticia_screen.dart';
import 'package:atividade11/screens/feed_noticias_screen.dart';
import 'package:atividade11/services/noticia_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _corpoCompleto =
    'Conteudo completo da primeira noticia, que so aparece inteiro no detalhe.';

final _postsJson = jsonEncode([
  {'id': 1, 'userId': 1, 'title': 'Primeira noticia', 'body': _corpoCompleto},
  {'id': 2, 'userId': 2, 'title': 'Segunda noticia', 'body': 'Curta'},
]);

final _comentariosJson = jsonEncode([
  {
    'id': 1,
    'postId': 1,
    'name': 'Ana Souza',
    'email': 'ana@exemplo.com',
    'body': 'Otima noticia!',
  },
  {
    'id': 2,
    'postId': 1,
    'name': 'Bruno Lima',
    'email': 'bruno@exemplo.com',
    'body': 'Concordo.',
  },
]);

/// Responde posts e comentarios conforme o caminho da URL.
MockClient _clientApi() {
  return MockClient((request) async {
    if (request.url.path.endsWith('/comments')) {
      return http.Response(_comentariosJson, 200);
    }
    return http.Response(_postsJson, 200);
  });
}

Future<void> _abrirFeed(WidgetTester tester, http.Client client) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FeedNoticiasScreen(service: NoticiaService(client: client)),
    ),
  );
}

void main() {
  group('FeedNoticiasScreen', () {
    testWidgets('mostra loading enquanto a requisicao nao termina', (
      tester,
    ) async {
      final resposta = Completer<http.Response>();
      await _abrirFeed(tester, MockClient((request) => resposta.future));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      resposta.complete(http.Response('[]', 200));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('mostra o erro quando a API falha', (tester) async {
      await _abrirFeed(
        tester,
        MockClient((request) async => http.Response('', 500)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Status HTTP de erro: 500'), findsOneWidget);
      expect(find.text('Tentar Novamente'), findsOneWidget);
    });

    testWidgets('mostra o estado vazio', (tester) async {
      await _abrirFeed(
        tester,
        MockClient((request) async => http.Response('[]', 200)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma notícia encontrada.'), findsOneWidget);
    });

    testWidgets('mostra os cards no sucesso', (tester) async {
      await _abrirFeed(tester, _clientApi());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Primeira noticia'), findsOneWidget);
      expect(find.text('Curta'), findsOneWidget);
    });

    testWidgets('tocar no card abre o detalhe com o objeto da lista', (
      tester,
    ) async {
      await _abrirFeed(tester, _clientApi());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Primeira noticia'));
      await tester.pumpAndSettle();

      final detalhe = find.byType(DetalheNoticiaScreen);
      expect(detalhe, findsOneWidget);
      expect(
        find.descendant(of: detalhe, matching: find.text(_corpoCompleto)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: detalhe, matching: find.text('Autor ID 1')),
        findsOneWidget,
      );
    });

    testWidgets('favoritar volta para o feed com coracao no card', (
      tester,
    ) async {
      await _abrirFeed(tester, _clientApi());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsNothing);

      await tester.tap(find.text('Primeira noticia'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(find.byType(DetalheNoticiaScreen), findsNothing);
      expect(find.text('Adicionada aos favoritos'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Abrir de novo mostra o coracao preenchido; desfavoritar remove.
      await tester.tap(find.text('Primeira noticia'));
      await tester.pumpAndSettle();
      final detalhe = find.byType(DetalheNoticiaScreen);
      await tester.tap(
        find.descendant(of: detalhe, matching: find.byIcon(Icons.favorite)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Removida dos favoritos'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('voltar pela seta da AppBar nao altera favoritos', (
      tester,
    ) async {
      await _abrirFeed(tester, _clientApi());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Primeira noticia'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(DetalheNoticiaScreen), findsNothing);
      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('DetalheNoticiaScreen', () {
    final noticia = NoticiaModel.fromJson({
      'id': 1,
      'userId': 1,
      'title': 'Primeira noticia',
      'body': _corpoCompleto,
    });

    testWidgets('mostra os comentarios vindos do servico', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetalheNoticiaScreen(
            noticia: noticia,
            service: NoticiaService(client: _clientApi()),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Comentários'), findsOneWidget);
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('bruno@exemplo.com'), findsOneWidget);
      expect(find.text('Otima noticia!'), findsOneWidget);
    });

    testWidgets('mostra erro quando os comentarios falham', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetalheNoticiaScreen(
            noticia: noticia,
            service: NoticiaService(
              client: MockClient((request) async => http.Response('', 503)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Erro ao carregar comentários'),
        findsOneWidget,
      );
    });

    testWidgets('mostra mensagem quando nao ha comentarios', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetalheNoticiaScreen(
            noticia: noticia,
            service: NoticiaService(
              client: MockClient((request) async => http.Response('[]', 200)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhum comentário ainda.'), findsOneWidget);
    });
  });
}
