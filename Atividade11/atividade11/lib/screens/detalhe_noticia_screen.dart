import 'package:flutter/material.dart';

import '../models/comentario_model.dart';
import '../models/noticia_model.dart';
import '../services/noticia_service.dart';
import '../theme/tema_web2.dart';
import '../utils/tags.dart';

class DetalheNoticiaScreen extends StatefulWidget {
  final NoticiaModel noticia;
  final bool favorita;
  final NoticiaService? service;

  const DetalheNoticiaScreen({
    super.key,
    required this.noticia,
    this.favorita = false,
    this.service,
  });

  @override
  State<DetalheNoticiaScreen> createState() => _DetalheNoticiaScreenState();
}

class _DetalheNoticiaScreenState extends State<DetalheNoticiaScreen> {
  late final Future<List<ComentarioModel>> _futureComentarios;

  @override
  void initState() {
    super.initState();
    final service = widget.service ?? NoticiaService();
    _futureComentarios = service.buscarComentarios(widget.noticia.id);
  }

  @override
  Widget build(BuildContext context) {
    final noticia = widget.noticia;
    final favorita = widget.favorita;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const FundoMetalEscovado(),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemaforoAqua(),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Detalhes da Notícia',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              favorita ? Icons.favorite : Icons.favorite_border,
              color: favorita ? Colors.red : CoresWeb2.rosa,
            ),
            tooltip: favorita ? 'Remover dos favoritos' : 'Favoritar',
            // Devolve o novo estado para o feed (true = favoritou).
            onPressed: () => Navigator.pop(context, !favorita),
          ),
        ],
      ),
      body: FundoPinstripe(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CapaComReflexo(noticia: noticia),
              CaixaWeb2(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Chip(
                            avatar: const Icon(Icons.person, size: 18),
                            label: Text(
                              noticia.autor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'post #${noticia.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: CoresWeb2.textoSuave,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      noticia.titulo,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CoresWeb2.texto,
                        letterSpacing: -0.5,
                        shadows: const [
                          Shadow(offset: Offset(0, 1), color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _TagsDaNoticia(titulo: noticia.titulo),
                    const Divider(height: 32),
                    Text(
                      noticia.conteudoCompleto,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: CoresWeb2.texto,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _LinkPermanente(
                      url: '${NoticiaService.urlBase}/${noticia.id}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              CaixaWeb2(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const BolhaBrilhante(
                          cor: CoresWeb2.lima,
                          tamanho: 30,
                          child: Icon(
                            Icons.forum,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Comentários',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _construirComentarios(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirComentarios() {
    return FutureBuilder<List<ComentarioModel>>(
      future: _futureComentarios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    'Carregando comentários...',
                    style: TextStyle(fontSize: 12, color: CoresWeb2.textoSuave),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Erro ao carregar comentários: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final comentarios = snapshot.data ?? [];
        if (comentarios.isEmpty) {
          return const Text('Nenhum comentário ainda.');
        }

        // Column + map em vez de ListView aninhado no SingleChildScrollView.
        // Os baloes alternam de lado, como numa conversa do iChat.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${comentarios.length} comentário(s) nesta conversa',
              style: const TextStyle(fontSize: 11, color: CoresWeb2.textoSuave),
            ),
            const SizedBox(height: 10),
            for (final (indice, comentario) in comentarios.indexed)
              _BalaoComentario(comentario: comentario, aDireita: indice.isOdd),
          ],
        );
      },
    );
  }
}

/// Capa com Hero e o reflexo espelhado embaixo ("wet floor").
class _CapaComReflexo extends StatelessWidget {
  final NoticiaModel noticia;

  const _CapaComReflexo({required this.noticia});

  Widget _imagem() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        noticia.urlImagem,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [CoresWeb2.aqua, CoresWeb2.aquaClaro],
              ),
            ),
            child: const Icon(Icons.photo, size: 72, color: Colors.white),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(tag: 'noticia-${noticia.id}', child: _imagem()),
        // Reflexo: a imagem invertida, cortada e esmaecendo para baixo.
        ExcludeSemantics(
          child: SizedBox(
            height: 46,
            child: ClipRect(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (area) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ).createShader(area),
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: 200,
                  child: Transform.flip(flipY: true, child: _imagem()),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Palavras do titulo como etiquetas coloridas.
class _TagsDaNoticia extends StatelessWidget {
  final String titulo;

  const _TagsDaNoticia({required this.titulo});

  @override
  Widget build(BuildContext context) {
    final palavras = extrairPalavras(titulo);
    if (palavras.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (indice, palavra) in palavras.indexed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: paletaWeb2[indice % paletaWeb2.length].withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: paletaWeb2[indice % paletaWeb2.length].withValues(
                  alpha: 0.5,
                ),
              ),
            ),
            child: Text(
              '#$palavra',
              style: TextStyle(
                fontSize: 11,
                color: Color.lerp(
                  paletaWeb2[indice % paletaWeb2.length],
                  Colors.black,
                  0.25,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Caixinha de "permalink", onipresente nos blogs da epoca.
class _LinkPermanente extends StatelessWidget {
  final String url;

  const _LinkPermanente({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CoresWeb2.borda),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: CoresWeb2.textoSuave),
          const SizedBox(width: 6),
          const Text(
            'link permanente: ',
            style: TextStyle(fontSize: 11, color: CoresWeb2.textoSuave),
          ),
          Expanded(
            child: Text(
              url.replaceFirst('https://', ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: CoresWeb2.aquaEscuro,
                decoration: TextDecoration.underline,
                decorationColor: CoresWeb2.aquaEscuro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Balao de conversa no estilo iChat, com avatar de gel.
class _BalaoComentario extends StatelessWidget {
  final ComentarioModel comentario;
  final bool aDireita;

  const _BalaoComentario({required this.comentario, required this.aDireita});

  String get _iniciais {
    final partes = comentario.nome
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .take(2);
    if (partes.isEmpty) return '?';
    return partes.map((parte) => parte[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final corBalao = aDireita ? CoresWeb2.lima : CoresWeb2.aqua;
    final avatar = BolhaBrilhante(
      cor: paletaWeb2[comentario.id % paletaWeb2.length],
      child: Text(
        _iniciais,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );

    // O canto proximo ao avatar fica "pontudo", como a ponta do balao.
    const redondo = Radius.circular(18);
    const ponta = Radius.circular(4);
    final borda = BorderRadius.only(
      topLeft: redondo,
      topRight: redondo,
      bottomLeft: aDireita ? redondo : ponta,
      bottomRight: aDireita ? ponta : redondo,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: aDireita
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!aDireita) ...[avatar, const SizedBox(width: 8)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                borderRadius: borda,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(corBalao, Colors.white, 0.85)!,
                    Color.lerp(corBalao, Colors.white, 0.6)!,
                  ],
                ),
                border: Border.all(
                  color: Color.lerp(corBalao, Colors.white, 0.2)!,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comentario.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    comentario.email,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color.lerp(corBalao, Colors.black, 0.35),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(comentario.texto),
                ],
              ),
            ),
          ),
          if (aDireita) ...[const SizedBox(width: 8), avatar],
        ],
      ),
    );
  }
}
