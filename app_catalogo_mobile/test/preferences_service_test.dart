import 'package:app_catalogo_mobile/services/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PreferencesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = PreferencesService();
  });

  group('nome do usuário', () {
    test('retorna "Usuário Convidado" quando não há valor salvo', () async {
      expect(await service.obterNomeUsuario(), 'Usuário Convidado');
    });

    test('salva e lê o nome informado', () async {
      await service.salvarNomeUsuario('Felipe');
      expect(await service.obterNomeUsuario(), 'Felipe');
    });
  });

  group('modo escuro', () {
    test('é falso por padrão', () async {
      expect(await service.obterModoEscuro(), isFalse);
    });

    test('salva e lê o valor verdadeiro', () async {
      await service.salvarModoEscuro(true);
      expect(await service.obterModoEscuro(), isTrue);
    });
  });

  group('último acesso', () {
    test('é nulo quando não há valor salvo', () async {
      expect(await service.obterUltimoAcesso(), isNull);
    });

    test('salva e lê o mesmo instante', () async {
      final agora = DateTime(2026, 10, 26, 10, 46, 30, 123);
      await service.salvarUltimoAcesso(agora);
      expect(await service.obterUltimoAcesso(), agora);
    });
  });

  group('histórico de pesquisas', () {
    test('é vazio por padrão', () async {
      expect(await service.obterHistorico(), isEmpty);
    });

    test('salva e lê a mesma lista', () async {
      final historico = [
        {'termo': 'flutter', 'data': '2026-10-26T10:00:00.000'},
        {'termo': 'dart', 'data': '2026-10-25T09:30:00.000'},
      ];
      await service.salvarHistorico(historico);
      expect(await service.obterHistorico(), historico);
    });

    test('retorna lista vazia quando o JSON está corrompido', () async {
      SharedPreferences.setMockInitialValues({
        'key_historico_pesquisas': '[{"termo": "flutter",',
      });
      expect(await service.obterHistorico(), isEmpty);
    });

    test('retorna lista vazia quando o JSON não é uma lista', () async {
      SharedPreferences.setMockInitialValues({
        'key_historico_pesquisas': '{"termo": "flutter"}',
      });
      expect(await service.obterHistorico(), isEmpty);
    });
  });

  test('limparTudo volta todas as preferências aos padrões', () async {
    await service.salvarNomeUsuario('Felipe');
    await service.salvarModoEscuro(true);
    await service.salvarUltimoAcesso(DateTime(2026, 10, 26));
    await service.salvarHistorico([
      {'termo': 'flutter', 'data': '2026-10-26T10:00:00.000'},
    ]);

    await service.limparTudo();

    expect(await service.obterNomeUsuario(), 'Usuário Convidado');
    expect(await service.obterModoEscuro(), isFalse);
    expect(await service.obterUltimoAcesso(), isNull);
    expect(await service.obterHistorico(), isEmpty);
  });
}
