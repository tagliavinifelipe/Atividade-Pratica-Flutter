/// Quebra o titulo em palavras minusculas que servem como tags.
/// Ignora palavras curtas (artigos, preposicoes) para a nuvem nao poluir.
List<String> extrairPalavras(String titulo) {
  return titulo
      .toLowerCase()
      .split(RegExp(r'[^a-zà-ÿ]+'))
      .where((palavra) => palavra.length >= 4)
      .toSet()
      .toList();
}

/// Conta as palavras de todos os titulos e devolve as mais frequentes,
/// em ordem alfabetica (como as nuvens de tags da epoca).
List<MapEntry<String, int>> montarNuvemDeTags(
  Iterable<String> titulos, {
  int limite = 14,
}) {
  final contagem = <String, int>{};
  for (final titulo in titulos) {
    for (final palavra in extrairPalavras(titulo)) {
      contagem[palavra] = (contagem[palavra] ?? 0) + 1;
    }
  }

  final maisFrequentes = contagem.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return maisFrequentes.take(limite).toList()
    ..sort((a, b) => a.key.compareTo(b.key));
}
