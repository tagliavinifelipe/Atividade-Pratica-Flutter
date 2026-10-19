import 'package:atividade11/models/noticia_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoticiaModel.fromJson', () {
    test('mapeia um JSON completo', () {
      const corpo =
          'Texto completo da noticia com mais de quarenta caracteres.';
      final noticia = NoticiaModel.fromJson({
        'id': 5,
        'userId': 3,
        'title': 'Titulo da noticia',
        'body': corpo,
      });

      expect(noticia.id, 5);
      expect(noticia.titulo, 'Titulo da noticia');
      expect(noticia.conteudoCompleto, corpo);
      expect(noticia.autor, 'Autor ID 3');
      expect(noticia.urlImagem, 'https://picsum.photos/seed/5/600/300');
    });

    test('body curto nao quebra e nao ganha reticencias', () {
      final noticia = NoticiaModel.fromJson({'id': 1, 'body': 'Curto'});

      expect(noticia.resumo, 'Curto');
      expect(noticia.conteudoCompleto, 'Curto');
    });

    test('body com exatamente 40 caracteres nao e cortado', () {
      final corpo = 'a' * 40;
      final noticia = NoticiaModel.fromJson({'id': 1, 'body': corpo});

      expect(noticia.resumo, corpo);
    });

    test('body longo e cortado em 40 caracteres com reticencias', () {
      final corpo = '${'b' * 40}resto que deve sumir';
      final noticia = NoticiaModel.fromJson({'id': 1, 'body': corpo});

      expect(noticia.resumo, '${'b' * 40}...');
      expect(noticia.conteudoCompleto, corpo);
    });

    test('body nulo gera resumo vazio e conteudo padrao', () {
      final noticia = NoticiaModel.fromJson({'id': 1});

      expect(noticia.resumo, '');
      expect(noticia.conteudoCompleto, 'Sem conteúdo disponível.');
      expect(noticia.titulo, 'Sem título');
    });

    test('autor sai no formato Autor ID', () {
      final noticia = NoticiaModel.fromJson({'id': 1, 'userId': 3});

      expect(noticia.autor, 'Autor ID 3');
    });
  });
}
