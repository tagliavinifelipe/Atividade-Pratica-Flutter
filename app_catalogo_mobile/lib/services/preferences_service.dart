import 'package:shared_preferences/shared_preferences.dart';

/// Isola todo o acesso ao SharedPreferences. A interface nunca deve
/// chamar o SharedPreferences diretamente, apenas este serviço.
class PreferencesService {
  // Chaves privadas para evitar erros de digitação espalhados pelo app
  static const String _keyNomeUsuario = 'key_nome_usuario';
  static const String _keyModoEscuro = 'key_modo_escuro';
  static const String _keyUltimoAcesso = 'key_ultimo_acesso';

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

  Future<void> limparTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
