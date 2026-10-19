import 'dart:async';
import 'dart:convert';

import 'package:atividade10/screens/detalhe_noticia_screen.dart';
import 'package:atividade10/screens/feed_noticias_screen.dart';
import 'package:atividade10/services/noticia_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _corpoLongo =
    'Este e o texto completo da primeira noticia, que aparece inteiro '
    'somente na tela de detalhes.';

final _postsJson = jsonEncode([
  {
    'id': 1,
    'userId': 1,
    'title': 'Flutter lanca versao nova',
    'body': _corpoLongo,
  },
  {'id': 2, 'userId': 1, 'title': 'Dart ganha recurso', 'body': 'Corpo 2'},
  {
    'id': 3,
    'userId': 2,
    'title': 'Outra noticia de Flutter',
    'body': 'Corpo 3',
  },
]);

http.Response _sucesso(http.Request request) => http.Response(_postsJson, 200);

Future<void> _abrirFeed(WidgetTester tester, http.Client client) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FeedNoticiasScreen(service: NoticiaService(client: client)),
    ),
  );
}

void main() {
  testWidgets('mostra o indicador de loading enquanto carrega', (tester) async {
    final resposta = Completer<http.Response>();
    await _abrirFeed(tester, MockClient((request) => resposta.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Card), findsNothing);

    resposta.complete(http.Response(_postsJson, 200));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('mostra os cards quando a requisicao tem sucesso', (
    tester,
  ) async {
    await _abrirFeed(tester, MockClient((request) async => _sucesso(request)));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(3));
    expect(find.text('Flutter lanca versao nova'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('mostra o estado vazio quando a API retorna lista vazia', (
    tester,
  ) async {
    await _abrirFeed(
      tester,
      MockClient((request) async => http.Response('[]', 200)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma notícia encontrada.'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('no erro, Tentar Novamente recarrega o feed', (tester) async {
    var chamadas = 0;
    final client = MockClient((request) async {
      chamadas++;
      if (chamadas == 1) return http.Response('', 500);
      return _sucesso(request);
    });

    await _abrirFeed(tester, client);
    await tester.pumpAndSettle();

    expect(find.textContaining('Status HTTP de erro: 500'), findsOneWidget);
    expect(find.text('Tentar Novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar Novamente'));
    await tester.pumpAndSettle();

    expect(chamadas, 2);
    expect(find.text('Tentar Novamente'), findsNothing);
    expect(find.byType(Card), findsNWidgets(3));
  });

  testWidgets('digitar no filtro reduz os cards', (tester) async {
    await _abrirFeed(tester, MockClient((request) async => _sucesso(request)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'FLUTTER');
    await tester.pump();

    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('Dart ganha recurso'), findsNothing);

    await tester.enterText(find.byType(TextField), 'kotlin');
    await tester.pump();

    expect(find.byType(Card), findsNothing);
    expect(find.text('Nenhuma notícia corresponde à busca.'), findsOneWidget);
  });

  testWidgets('tocar no card abre o detalhe com o texto completo', (
    tester,
  ) async {
    await _abrirFeed(tester, MockClient((request) async => _sucesso(request)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flutter lanca versao nova'));
    await tester.pumpAndSettle();

    final detalhe = find.byType(DetalheNoticiaScreen);
    expect(detalhe, findsOneWidget);
    expect(
      find.descendant(of: detalhe, matching: find.text(_corpoLongo)),
      findsOneWidget,
    );
  });

  testWidgets(
    'simulacao de erro mostra o estado de erro e pode ser desligada',
    (tester) async {
      final client = MockClient((request) async {
        if (request.url.host == 'api-inexistente.invalid') {
          throw http.ClientException('host nao encontrado');
        }
        return _sucesso(request);
      });

      await _abrirFeed(tester, client);
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNWidgets(3));

      await tester.tap(find.byTooltip('Simular erro de conexão'));
      await tester.pumpAndSettle();

      expect(find.text('Simulação de erro ativada'), findsOneWidget);
      expect(
        find.textContaining('Falha ao conectar com a API'),
        findsOneWidget,
      );
      expect(find.text('Tentar Novamente'), findsOneWidget);
      final icone = tester.widget<Icon>(find.byIcon(Icons.bug_report));
      expect(icone.color, Colors.red);

      await tester.tap(find.byTooltip('Simular erro de conexão'));
      await tester.pumpAndSettle();

      expect(find.text('Simulação de erro desativada'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    },
  );
}
