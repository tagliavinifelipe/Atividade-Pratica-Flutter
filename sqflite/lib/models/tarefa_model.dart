class TarefaModel {
  final int? id;
  final String titulo;
  final String descricao;
  final bool concluida;

  TarefaModel({
    this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
  });

  // Converte o objeto em Map para gravar no SQLite (bool vira 0/1).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
    };
  }

  // Reconstrói o objeto a partir de uma linha retornada pelo SQLite.
  factory TarefaModel.fromMap(Map<String, dynamic> map) {
    return TarefaModel(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      concluida: (map['concluida'] as int) == 1,
    );
  }

  TarefaModel copyWith({
    int? id,
    String? titulo,
    String? descricao,
    bool? concluida,
  }) {
    return TarefaModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
    );
  }
}
