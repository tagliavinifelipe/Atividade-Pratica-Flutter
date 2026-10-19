import 'package:atividade10/models/noticia_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoticiaModel.fromJson', () {
    test('mapeia um JSON completo', () {
      final noticia = NoticiaModel.fromJson({
        'id': 7,
        'userId': 3,
        'title': 'Titulo da noticia',
        'body': 'Corpo da noticia',
      });

      expect(noticia.id, 7);
      expect(noticia.autorId, 3);
      expect(noticia.titulo, 'Titulo da noticia');
      expect(noticia.resumo, 'Corpo da noticia');
    });

    test('usa os valores padrao para um JSON vazio', () {
      final noticia = NoticiaModel.fromJson({});

      expect(noticia.id, 0);
      expect(noticia.autorId, 0);
      expect(noticia.titulo, '');
      expect(noticia.resumo, '');
    });
  });
}
