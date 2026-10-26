import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Isola todo o acesso ao SharedPreferences. A interface nunca deve
/// chamar o SharedPreferences diretamente, apenas este serviço.
class PreferencesService {
  // Chaves privadas para evitar erros de digitação espalhados pelo app
  static const String _keyNomeUsuario = 'key_nome_usuario';
  static const String _keyModoEscuro = 'key_modo_escuro';
  static const String _keyUltimoAcesso = 'key_ultimo_acesso';
  static const String _keyHistoricoPesquisas = 'key_historico_pesquisas';

  Future<void> salvarNomeUsuario(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNomeUsuario, nome);
  }

  Future<String> obterNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNomeUsuario) ?? 'Usuário Convidado';
  }

  Future<void> salvarModoEscuro(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyModoEscuro, valor);
  }

  Future<bool> obterModoEscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyModoEscuro) ?? false;
  }

  // DateTime não é um tipo suportado: gravamos como texto ISO 8601
  Future<void> salvarUltimoAcesso(DateTime data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUltimoAcesso, data.toIso8601String());
  }

  Future<DateTime?> obterUltimoAcesso() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getString(_keyUltimoAcesso);
    if (valor == null) return null;
    return DateTime.tryParse(valor);
  }

  // Listas de objetos não são suportadas: serializamos tudo em uma String JSON
  Future<void> salvarHistorico(List<Map<String, dynamic>> historico) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHistoricoPesquisas, jsonEncode(historico));
  }

  Future<List<Map<String, dynamic>>> obterHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyHistoricoPesquisas);
    if (jsonString == null) return [];

    try {
      final decodificado = jsonDecode(jsonString);
      if (decodificado is! List) return [];
      return decodificado.whereType<Map<String, dynamic>>().toList();
    } on FormatException {
      // JSON corrompido no disco: trata como histórico vazio
      return [];
    }
  }

  Future<void> limparTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
