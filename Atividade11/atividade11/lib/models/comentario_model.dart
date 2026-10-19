class ComentarioModel {
  final int id;
  final int postId;
  final String nome;
  final String email;
  final String texto;

  ComentarioModel({
    required this.id,
    required this.postId,
    required this.nome,
    required this.email,
    required this.texto,
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      nome: json['name'] ?? '',
      email: json['email'] ?? '',
      texto: json['body'] ?? '',
    );
  }
}
