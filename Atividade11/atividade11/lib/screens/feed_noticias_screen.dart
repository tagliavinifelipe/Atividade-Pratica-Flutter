import 'package:flutter/material.dart';

import '../models/noticia_model.dart';
import '../services/noticia_service.dart';
import '../theme/tema_web2.dart';
import '../utils/tags.dart';
import 'detalhe_noticia_screen.dart';

class FeedNoticiasScreen extends StatefulWidget {
  final NoticiaService? service;

  const FeedNoticiasScreen({super.key, this.service});

  @override
  State<FeedNoticiasScreen> createState() => _FeedNoticiasScreenState();
}

class _FeedNoticiasScreenState extends State<FeedNoticiasScreen> {
  late final NoticiaService _service;
  late Future<List<NoticiaModel>> _futureNoticias;
  final Set<int> _favoritos = {};
  String? _tagSelecionada;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NoticiaService();
    _futureNoticias = _service.buscarNoticias();
  }

  void _recarregar() {
    setState(() {
      _tagSelecionada = null;
      _futureNoticias = _service.buscarNoticias();
    });
  }

  Future<void> _abrirDetalhes(NoticiaModel noticia) async {
    // Passa o objeto ja carregado; o detalhe nao faz nova requisicao.
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheNoticiaScreen(
          noticia: noticia,
          favorita: _favoritos.contains(noticia.id),
          service: _service,
        ),
      ),
    );
    if (!mounted) return;

    // Voltar pela seta da AppBar retorna null: nada muda.
    if (resultado == null) return;

    setState(() {
      if (resultado) {
        _favoritos.add(noticia.id);
      } else {
        _favoritos.remove(noticia.id);
      }
    });

    // Notificacao no estilo Growl.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        criarGrowl(
          titulo: 'Favoritos',
          mensagem: resultado
              ? 'Adicionada aos favoritos'
              : 'Removida dos favoritos',
          icone: resultado ? Icons.bookmark_added : Icons.bookmark_remove,
          cor: resultado ? CoresWeb2.rosa : CoresWeb2.textoSuave,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const FundoMetalEscovado(),
        leadingWidth: 70,
        leading: const Center(child: SemaforoAqua()),
        centerTitle: true,
        title: const LogoWeb2(texto: 'notícias'),
        actions: [
          IconButton(
            tooltip: 'Atualizar feed',
            onPressed: _recarregar,
            icon: const IconeRss(),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FundoPinstripe(
        child: FutureBuilder<List<NoticiaModel>>(
          future: _futureNoticias,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CaixaWeb2(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 14),
                      Text(
                        'Carregando o feed...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'buscando as notícias mais quentes da web',
                        style: TextStyle(
                          fontSize: 11,
                          color: CoresWeb2.textoSuave,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return _PainelErro(
                mensagem: 'Erro: ${snapshot.error}',
                onTentarNovamente: _recarregar,
              );
            }

            final noticias = snapshot.data ?? [];
            if (noticias.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(opacity: 0.35, child: IconeRss(tamanho: 72)),
                    SizedBox(height: 14),
                    Text(
                      'Nenhuma notícia encontrada.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Volte mais tarde para novidades.',
                      style: TextStyle(
                        fontSize: 12,
                        color: CoresWeb2.textoSuave,
                      ),
                    ),
                  ],
                ),
              );
            }

            return _construirLista(noticias);
          },
        ),
      ),
    );
  }

  Widget _construirLista(List<NoticiaModel> noticias) {
    final tags = montarNuvemDeTags(noticias.map((noticia) => noticia.titulo));
    final tagSelecionada = _tagSelecionada;
    final filtradas = tagSelecionada == null
        ? noticias
        : noticias
              .where(
                (noticia) =>
                    extrairPalavras(noticia.titulo).contains(tagSelecionada),
              )
              .toList();

    // Item 0 e a nuvem de tags; os demais sao os cards.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: filtradas.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _NuvemDeTags(
            tags: tags,
            selecionada: tagSelecionada,
            totalFiltrado: filtradas.length,
            onSelecionar: (tag) => setState(() => _tagSelecionada = tag),
          );
        }

        final posicao = index - 1;
        final noticia = filtradas[posicao];
        return _CardNoticia(
          noticia: noticia,
          nova: posicao < 3,
          favorita: _favoritos.contains(noticia.id),
          onTap: () => _abrirDetalhes(noticia),
        );
      },
    );
  }
}

class _CardNoticia extends StatelessWidget {
  final NoticiaModel noticia;
  final bool nova;
  final bool favorita;
  final VoidCallback onTap;

  const _CardNoticia({
    required this.noticia,
    required this.nova,
    required this.favorita,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Ink(
              // Leve brilho no topo do card.
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFF3F8FD)],
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
                leading: Hero(
                  tag: 'noticia-${noticia.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        noticia.urlImagem,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const _MiniaturaReserva(tamanho: 56);
                        },
                      ),
                    ),
                  ),
                ),
                title: Text(
                  noticia.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(noticia.resumo),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 13,
                          color: CoresWeb2.aqua,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'por ${noticia.autor}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: CoresWeb2.aqua,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (favorita) ...[
                      const Icon(Icons.favorite, color: Colors.red),
                      const SizedBox(width: 4),
                    ],
                    const BolhaBrilhante(
                      cor: CoresWeb2.aqua,
                      tamanho: 24,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                onTap: onTap,
              ),
            ),
          ),
          if (nova) const Positioned(top: -14, right: -8, child: SeloNovo()),
        ],
      ),
    );
  }
}

/// Imagem de reserva: ceu azul com icone de foto (quando a rede falha).
class _MiniaturaReserva extends StatelessWidget {
  final double tamanho;

  const _MiniaturaReserva({required this.tamanho});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CoresWeb2.aquaClaro, Color(0xFFE8F5FF)],
        ),
      ),
      child: Icon(Icons.photo, color: Colors.white, size: tamanho * 0.5),
    );
  }
}

/// Nuvem de tags: palavras mais frequentes nos titulos, com tamanho
/// proporcional a frequencia. Tocar em uma tag filtra o feed.
class _NuvemDeTags extends StatelessWidget {
  final List<MapEntry<String, int>> tags;
  final String? selecionada;
  final int totalFiltrado;
  final ValueChanged<String?> onSelecionar;

  const _NuvemDeTags({
    required this.tags,
    required this.selecionada,
    required this.totalFiltrado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    final menor = tags.map((tag) => tag.value).reduce((a, b) => a < b ? a : b);
    final maior = tags.map((tag) => tag.value).reduce((a, b) => a > b ? a : b);

    double tamanhoDaFonte(int ocorrencias) {
      if (maior == menor) return 15;
      return 12 + (ocorrencias - menor) / (maior - menor) * 12;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: CaixaWeb2(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sell, size: 16, color: CoresWeb2.laranja),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'tags populares',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                if (selecionada != null)
                  InkWell(
                    onTap: () => onSelecionar(null),
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'limpar filtro',
                            style: TextStyle(
                              fontSize: 11,
                              color: CoresWeb2.rosa,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.close, size: 13, color: CoresWeb2.rosa),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final (indice, tag) in tags.indexed)
                  InkWell(
                    onTap: () =>
                        onSelecionar(tag.key == selecionada ? null : tag.key),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: tag.key == selecionada
                          ? BoxDecoration(
                              color: const Color(0xFFFFF3B0),
                              borderRadius: BorderRadius.circular(6),
                            )
                          : null,
                      child: Text(
                        tag.key,
                        style: TextStyle(
                          fontSize: tamanhoDaFonte(tag.value),
                          fontWeight: tag.value == maior
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: paletaWeb2[indice % paletaWeb2.length],
                          decoration: tag.key == selecionada
                              ? TextDecoration.underline
                              : null,
                          decorationColor:
                              paletaWeb2[indice % paletaWeb2.length],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (selecionada != null) ...[
              const SizedBox(height: 8),
              Text(
                totalFiltrado == 0
                    ? 'Nenhuma notícia com a tag "$selecionada".'
                    : '$totalFiltrado notícia(s) com a tag "$selecionada"',
                style: const TextStyle(
                  fontSize: 11,
                  color: CoresWeb2.textoSuave,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Painel de erro no estilo dos alertas do Mac OS X.
class _PainelErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentarNovamente;

  const _PainelErro({required this.mensagem, required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: CaixaWeb2(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BolhaBrilhante(
                cor: Color(0xFFE53935),
                tamanho: 56,
                child: Icon(Icons.priority_high, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ops! O feed não carregou.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 18),
              BotaoAqua(
                texto: 'Tentar Novamente',
                icone: Icons.refresh,
                onPressed: onTentarNovamente,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
