class NoticiaModel {
  final int id;
  final String titulo;
  final String resumo;
  final String conteudoCompleto;
  final String autor;
  final String urlImagem;

  NoticiaModel({
    required this.id,
    required this.titulo,
    required this.resumo,
    required this.conteudoCompleto,
    required this.autor,
    required this.urlImagem,
  });

  factory NoticiaModel.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] ?? 0;
    final String? corpo = json['body'];

    // So corta (e adiciona reticencias) quando o texto passa de 40 caracteres.
    String resumo = '';
    if (corpo != null) {
      resumo = corpo.length > 40 ? '${corpo.substring(0, 40)}...' : corpo;
    }

    return NoticiaModel(
      id: id,
      titulo: json['title'] ?? 'Sem título',
      resumo: resumo,
      conteudoCompleto: corpo ?? 'Sem conteúdo disponível.',
      autor: 'Autor ID ${json['userId'] ?? 0}',
      urlImagem: 'https://picsum.photos/seed/$id/600/300',
    );
  }
}
