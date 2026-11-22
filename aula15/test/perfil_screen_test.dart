import 'dart:io';

import 'package:aula15/screens/perfil_screen.dart';
import 'package:aula15/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMediaService extends MediaService {
  @override
  Future<File?> tirarFoto() async => null;

  @override
  Future<File?> selecionarDaGaleria() async => null;
}

Future<void> _abrirTela(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(home: PerfilScreen(mediaService: FakeMediaService())),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('estado inicial mostra o ícone de pessoa no avatar', (
    WidgetTester tester,
  ) async {
    await _abrirTela(tester);

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Perfil do Usuário'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nome Completo'), findsOneWidget);
  });

  testWidgets('bottom sheet mostra câmera e galeria, sem "Remover Foto"', (
    WidgetTester tester,
  ) async {
    await _abrirTela(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Tirar Foto com a Câmera'), findsOneWidget);
    expect(find.text('Escolher da Galeria'), findsOneWidget);
    expect(find.text('Remover Foto'), findsNothing);
  });

  testWidgets('cancelar a escolha mantém o avatar sem foto', (
    WidgetTester tester,
  ) async {
    await _abrirTela(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher da Galeria'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
