import 'package:flutter/material.dart';

import '../models/noticia_model.dart';
import '../services/noticia_service.dart';
import '../theme/tema_xp.dart';
import 'detalhe_noticia_screen.dart';

class FeedNoticiasScreen extends StatefulWidget {
  final NoticiaService? service;

  const FeedNoticiasScreen({super.key, this.service});

  @override
  State<FeedNoticiasScreen> createState() => _FeedNoticiasScreenState();
}

class _FeedNoticiasScreenState extends State<FeedNoticiasScreen> {
  late final NoticiaService _service;

  List<NoticiaModel> _noticias = [];
  bool _isLoading = true;
  String? _mensagemErro;
  String _filtro = '';
  bool _simularErro = false;

  List<NoticiaModel> get _noticiasFiltradas {
    final termo = _filtro.trim().toLowerCase();
    if (termo.isEmpty) return _noticias;
    return _noticias
        .where((noticia) => noticia.titulo.toLowerCase().contains(termo))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NoticiaService();
    _carregarFeed();
  }

  Future<void> _carregarFeed() async {
    setState(() {
      _isLoading = true;
      _mensagemErro = null;
    });

    try {
      final noticias = await _service.buscarNoticias(simularErro: _simularErro);
      if (!mounted) return;
      setState(() {
        _noticias = noticias;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensagemErro = 'Erro: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _alternarSimulacaoErro() {
    setState(() {
      _simularErro = !_simularErro;
    });

    // Balao da bandeja, como o aviso de "cabo de rede desconectado" do XP.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        _simularErro
            ? criarBalaoXp(
                titulo: 'Cabo de rede desconectado',
                mensagem: 'Simulação de erro ativada',
                icone: Icons.warning_amber_rounded,
                corIcone: Colors.orange,
              )
            : criarBalaoXp(
                titulo: 'Conexão de rede local',
                mensagem: 'Simulação de erro desativada',
                icone: Icons.lan,
                corIcone: CoresXp.verdeIniciar,
              ),
      );

    _carregarFeed();
  }

  // Mensagens no estilo da barra de status do Internet Explorer 6.
  String get _textoStatus {
    if (_isLoading) return 'Abrindo página ${_urlAtual()}...';
    if (_mensagemErro != null) return 'Erro na página.';
    final modo = _simularErro ? ' | Simulação de erro ligada' : '';
    return 'Concluído: ${_noticiasFiltradas.length} de '
        '${_noticias.length} notícia(s)$modo';
  }

  String _urlAtual() {
    return _simularErro
        ? NoticiaService.urlInexistente
        : NoticiaService.urlBase;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const FundoBarraTituloXp(),
        title: const Row(
          children: [
            Icon(Icons.language, size: 20),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Feed de Notícias - Microsoft Internet Explorer',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bug_report,
              color: _simularErro ? Colors.red : null,
            ),
            tooltip: 'Simular erro de conexão',
            onPressed: _alternarSimulacaoErro,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: _carregarFeed,
          ),
          const BotoesJanelaXp(),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: BarraTarefasXp(
        tarefa: 'Feed de Notícias - Microsoft Internet Explorer',
        redeDesconectada: _simularErro,
      ),
      body: Column(
        children: [
          const BarraMenuXp(
            itens: [
              'Arquivo',
              'Editar',
              'Exibir',
              'Favoritos',
              'Ferramentas',
              'Ajuda',
            ],
          ),
          _BarraFerramentasIe(onAtualizar: _carregarFeed),
          _BarraEndereco(url: _urlAtual(), onIr: _carregarFeed),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por título',
              ),
              onChanged: (valor) {
                setState(() {
                  _filtro = valor;
                });
              },
            ),
          ),
          // Area da "pagina web", com a borda afundada do IE.
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFF7F7F7F), width: 2),
                  left: BorderSide(color: Color(0xFF7F7F7F), width: 2),
                  right: BorderSide(color: Colors.white, width: 2),
                  bottom: BorderSide(color: Colors.white, width: 2),
                ),
              ),
              child: _construirCorpo(),
            ),
          ),
          BarraStatusXp(texto: _textoStatus),
        ],
      ),
    );
  }

  Widget _construirCorpo() {
    // Estado: Carregando
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 300,
            child: JanelaXp(
              titulo: 'Abrindo página...',
              icone: Icons.language,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 14),
                      Expanded(child: Text('Aguarde, carregando notícias...')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const BlocosProgressoXp(),
                  const SizedBox(height: 6),
                  Text(
                    _urlAtual(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Estado: Erro (a famosa pagina "Nao e possivel exibir a pagina" do IE)
    if (_mensagemErro != null) {
      return _PaginaErroIe(
        mensagemErro: _mensagemErro!,
        onTentarNovamente: _carregarFeed,
      );
    }

    // Estado: Vazio
    if (_noticias.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 56, color: Color(0xFFE8B84A)),
            SizedBox(height: 8),
            Text('Nenhuma notícia encontrada.'),
            SizedBox(height: 12),
            PlacaEmConstrucao(),
          ],
        ),
      );
    }

    final noticiasFiltradas = _noticiasFiltradas;
    if (noticiasFiltradas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.manage_search, size: 48, color: CoresXp.azulSelecao),
              SizedBox(height: 8),
              Text(
                'Nenhuma notícia corresponde à busca.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Verifique se todas as palavras estão escritas corretamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    // Estado: Sucesso (o primeiro item e o cabecalho do "portal")
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: noticiasFiltradas.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const _CabecalhoPortal();

        final noticia = noticiasFiltradas[index - 1];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: CoresXp.verdeIniciar,
              foregroundColor: Colors.white,
              child: Text(
                '${noticia.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              noticia.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: CoresXp.azulLink,
              ),
            ),
            subtitle: Text(
              noticia.resumo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(
              Icons.keyboard_double_arrow_right,
              size: 18,
              color: CoresXp.azulSelecao,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalheNoticiaScreen(noticia: noticia),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Barra de botoes do IE6: Voltar, Avancar, Parar, Atualizar, Pagina inicial.
class _BarraFerramentasIe extends StatelessWidget {
  final VoidCallback onAtualizar;

  const _BarraFerramentasIe({required this.onAtualizar});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F6F0), CoresXp.bege],
        ),
        border: Border(
          top: BorderSide(color: Colors.white),
          bottom: BorderSide(color: CoresXp.begeEscuro),
        ),
      ),
      child: Row(
        children: [
          const _BotaoRedondoIe(
            icone: Icons.arrow_back,
            rotulo: 'Voltar',
            cor: Color(0xFF3AA53A),
          ),
          const _BotaoRedondoIe(
            icone: Icons.arrow_forward,
            cor: Color(0xFFA0A0A0),
          ),
          const _SeparadorIe(),
          const _BotaoSimplesIe(icone: Icons.close, cor: Color(0xFFD9452B)),
          _BotaoSimplesIe(
            icone: Icons.refresh,
            cor: const Color(0xFF2E9E2E),
            tooltip: 'Atualizar',
            onTap: onAtualizar,
          ),
          const _BotaoSimplesIe(icone: Icons.home, cor: Color(0xFF5B7FC7)),
          const _SeparadorIe(),
          const _BotaoSimplesIe(icone: Icons.star, cor: Color(0xFFF2B01E)),
          const Spacer(),
          // "Throbber" do IE: a bandeirinha no canto direito.
          Container(
            width: 34,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: CoresXp.begeEscuro),
            ),
            child: const BandeiraXp(),
          ),
        ],
      ),
    );
  }
}

class _BotaoRedondoIe extends StatelessWidget {
  final IconData icone;
  final String? rotulo;
  final Color cor;

  const _BotaoRedondoIe({required this.icone, required this.cor, this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                colors: [Color.lerp(cor, Colors.white, 0.5)!, cor],
              ),
              border: Border.all(color: Color.lerp(cor, Colors.black, 0.3)!),
            ),
            child: Icon(icone, size: 16, color: Colors.white),
          ),
          if (rotulo != null) ...[
            const SizedBox(width: 4),
            Text(rotulo!, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _BotaoSimplesIe extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String? tooltip;
  final VoidCallback? onTap;

  const _BotaoSimplesIe({
    required this.icone,
    required this.cor,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final botao = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icone, size: 20, color: cor),
      ),
    );
    return tooltip == null ? botao : Tooltip(message: tooltip, child: botao);
  }
}

class _SeparadorIe extends StatelessWidget {
  const _SeparadorIe();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: CoresXp.begeEscuro,
    );
  }
}

/// Barra "Endereco" com a URL que esta sendo carregada e o botao "Ir".
class _BarraEndereco extends StatelessWidget {
  final String url;
  final VoidCallback onIr;

  const _BarraEndereco({required this.url, required this.onIr});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: CoresXp.bege,
      child: Row(
        children: [
          const Text(
            'Endereço',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: CoresXp.bordaCampo),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.language,
                    size: 14,
                    color: CoresXp.azulSelecao,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onIr,
            child: const Row(
              children: [
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFF2E9E2E)),
                SizedBox(width: 2),
                Text('Ir', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecalho de "portal de noticias" de 2001, com contador de visitas.
class _CabecalhoPortal extends StatelessWidget {
  const _CabecalhoPortal();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDDE8FA), Colors.white],
        ),
        border: Border.all(color: CoresXp.bordaCampo),
      ),
      child: Row(
        children: [
          const Icon(Icons.newspaper, size: 30, color: CoresXp.azulTitulo),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portal de Notícias',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: CoresXp.azulTitulo,
                  ),
                ),
                Text(
                  'Melhor visualizado em 800x600',
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Text('visitas', style: TextStyle(fontSize: 9)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: Colors.black,
                child: const Text(
                  '001337',
                  style: TextStyle(
                    fontFamily: fonteBlocoDeNotas,
                    fontFamilyFallback: fontesReservaBlocoDeNotas,
                    color: Color(0xFF39FF14),
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pagina de erro classica do IE: "Nao e possivel exibir a pagina".
class _PaginaErroIe extends StatelessWidget {
  final String mensagemErro;
  final VoidCallback onTentarNovamente;

  const _PaginaErroIe({
    required this.mensagemErro,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    const dica = TextStyle(fontSize: 12, height: 1.4);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, size: 36, color: CoresXp.azulSelecao),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Não é possível exibir a página',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: CoresXp.azulLink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            mensagemErro,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onTentarNovamente,
            icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF2E9E2E)),
            label: const Text('Tentar Novamente'),
          ),
          const Divider(height: 28),
          const Text(
            'Tente o seguinte:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            '•  Clique no botão Atualizar ou tente novamente.',
            style: dica,
          ),
          const Text(
            '•  Verifique se o cabo de rede está conectado.',
            style: dica,
          ),
          const Text(
            '•  Se a simulação de erro estiver ligada (ícone vermelho), '
            'desligue-a.',
            style: dica,
          ),
          const SizedBox(height: 12),
          const Text(
            'Não foi possível localizar o servidor ou erro de DNS\n'
            'Internet Explorer',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
