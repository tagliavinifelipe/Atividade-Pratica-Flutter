import 'package:atividade11/models/comentario_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComentarioModel.fromJson', () {
    test('mapeia um JSON completo', () {
      final comentario = ComentarioModel.fromJson({
        'id': 10,
        'postId': 2,
        'name': 'Maria',
        'email': 'maria@exemplo.com',
        'body': 'Gostei da noticia',
      });

      expect(comentario.id, 10);
      expect(comentario.postId, 2);
      expect(comentario.nome, 'Maria');
      expect(comentario.email, 'maria@exemplo.com');
      expect(comentario.texto, 'Gostei da noticia');
    });

    test('usa os valores padrao para um JSON vazio', () {
      final comentario = ComentarioModel.fromJson({});

      expect(comentario.id, 0);
      expect(comentario.postId, 0);
      expect(comentario.nome, '');
      expect(comentario.email, '');
      expect(comentario.texto, '');
    });
  });
}
