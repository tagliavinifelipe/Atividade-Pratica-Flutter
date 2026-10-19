import 'dart:convert';

import 'package:atividade11/screens/feed_noticias_screen.dart';
import 'package:atividade11/services/noticia_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('Feed exibe as noticias retornadas pelo servico', (tester) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {'id': 1, 'userId': 1, 'title': 'Primeira', 'body': 'Corpo 1'},
        ]),
        200,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: FeedNoticiasScreen(service: NoticiaService(client: client)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Primeira'), findsOneWidget);
  });
}
