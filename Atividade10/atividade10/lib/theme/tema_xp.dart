import 'package:flutter/material.dart';

/// Paleta inspirada no tema Luna do Windows XP (2001).
class CoresXp {
  static const azulTitulo = Color(0xFF0054E3);
  static const azulTituloClaro = Color(0xFF3D95FF);
  static const azulSelecao = Color(0xFF316AC5);
  static const azulLink = Color(0xFF0B3D91);
  static const bege = Color(0xFFECE9D8);
  static const begeEscuro = Color(0xFFD6D2C2);
  static const bordaCampo = Color(0xFF7F9DB9);
  static const bordaBotao = Color(0xFF003C74);
  static const verdeIniciar = Color(0xFF3C9A3C);
  static const vermelhoFechar = Color(0xFFE04343);
  static const amareloBalao = Color(0xFFFFFFE1);
  static const azulBarraTarefas = Color(0xFF245EDC);
  static const azulBandeja = Color(0xFF0F8DEB);
}

const String fonteXp = 'Tahoma';
const List<String> fontesReservaXp = ['Verdana', 'Segoe UI', 'sans-serif'];

/// Fonte padrao do Bloco de notas.
const String fonteBlocoDeNotas = 'Lucida Console';
const List<String> fontesReservaBlocoDeNotas = ['Courier New', 'monospace'];

ThemeData criarTemaXp() {
  final esquemaCores = ColorScheme.fromSeed(seedColor: CoresXp.azulTitulo)
      .copyWith(
        primary: CoresXp.azulTitulo,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquemaCores,
    fontFamily: fonteXp,
    fontFamilyFallback: fontesReservaXp,
    scaffoldBackgroundColor: CoresXp.bege,
    appBarTheme: const AppBarThemeData(
      backgroundColor: CoresXp.azulTitulo,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 8,
      titleTextStyle: TextStyle(
        fontFamily: fonteXp,
        fontFamilyFallback: fontesReservaXp,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(offset: Offset(1, 1), color: Color(0x99000000))],
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: const BorderSide(color: CoresXp.bordaCampo),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      titleTextStyle: TextStyle(
        fontFamily: fonteXp,
        fontFamilyFallback: fontesReservaXp,
        fontSize: 14,
        color: CoresXp.azulLink,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: fonteXp,
        fontFamilyFallback: fontesReservaXp,
        fontSize: 12,
        color: Colors.black87,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF4F3EE),
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        side: const BorderSide(color: CoresXp.bordaBotao),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        textStyle: const TextStyle(fontFamily: fonteXp, fontSize: 13),
      ),
    ),
    inputDecorationTheme: const InputDecorationThemeData(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: CoresXp.bordaCampo),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: CoresXp.azulSelecao, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: CoresXp.amareloBalao,
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      contentTextStyle: const TextStyle(
        fontFamily: fonteXp,
        fontFamilyFallback: fontesReservaXp,
        color: Colors.black,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black54),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: CoresXp.verdeIniciar,
    ),
    dividerTheme: const DividerThemeData(color: CoresXp.bordaCampo),
  );
}

/// Balao de notificacao da bandeja do XP, com titulo em negrito e icone.
SnackBar criarBalaoXp({
  required String titulo,
  required String mensagem,
  IconData icone = Icons.info,
  Color corIcone = CoresXp.azulSelecao,
}) {
  return SnackBar(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, size: 18, color: corIcone),
            const SizedBox(width: 6),
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(mensagem),
      ],
    ),
  );
}

/// Degrade azul da barra de titulo das janelas do XP.
class FundoBarraTituloXp extends StatelessWidget {
  const FundoBarraTituloXp({super.key});

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand: no flexibleSpace da AppBar as restricoes sao folgadas
    // e um DecoratedBox sem filho encolheria para tamanho zero.
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.12, 0.3, 0.8, 1.0],
            colors: [
              Color(0xFF6AB4FF),
              CoresXp.azulTituloClaro,
              CoresXp.azulTitulo,
              Color(0xFF0048D0),
              Color(0xFF002E96),
            ],
          ),
        ),
      ),
    );
  }
}

/// Os tres botoes do canto da janela: minimizar, maximizar e fechar.
/// Sao apenas decorativos.
class BotoesJanelaXp extends StatelessWidget {
  final double tamanho;

  const BotoesJanelaXp({super.key, this.tamanho = 21});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BotaoJanelaXp(icone: Icons.minimize, tamanho: tamanho),
          const SizedBox(width: 2),
          _BotaoJanelaXp(icone: Icons.crop_square, tamanho: tamanho),
          const SizedBox(width: 2),
          _BotaoJanelaXp(
            icone: Icons.close,
            tamanho: tamanho,
            cor: CoresXp.vermelhoFechar,
          ),
        ],
      ),
    );
  }
}

class _BotaoJanelaXp extends StatelessWidget {
  final IconData icone;
  final double tamanho;
  final Color cor;

  const _BotaoJanelaXp({
    required this.icone,
    required this.tamanho,
    this.cor = const Color(0xFF2B6FEF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(cor, Colors.white, 0.35)!, cor],
        ),
      ),
      child: Icon(icone, size: tamanho * 0.65, color: Colors.white),
    );
  }
}

/// Barra de menus classica ("Arquivo Editar Exibir...").
class BarraMenuXp extends StatelessWidget {
  final List<String> itens;

  const BarraMenuXp({super.key, required this.itens});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      color: CoresXp.bege,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRect(
        child: Row(
          children: [
            for (final item in itens)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text.rich(
                  TextSpan(
                    children: [
                      // Primeira letra sublinhada, como os atalhos com Alt.
                      TextSpan(
                        text: item.substring(0, 1),
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: item.substring(1)),
                    ],
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Moldura de janela do XP: barra de titulo azul, botoes decorativos,
/// barra de menus opcional e rodape opcional.
class JanelaXp extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final List<String>? menus;
  final Widget? rodape;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const JanelaXp({
    super.key,
    required this.titulo,
    required this.child,
    this.icone = Icons.article,
    this.menus,
    this.rodape,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CoresXp.bege,
        border: Border.all(color: const Color(0xFF0831D9), width: 3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(3, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            child: SizedBox(
              height: 28,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const FundoBarraTituloXp(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        Icon(icone, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  color: Color(0x99000000),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const BotoesJanelaXp(tamanho: 19),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (menus != null) BarraMenuXp(itens: menus!),
          Padding(padding: padding, child: child),
          ?rodape,
        ],
      ),
    );
  }
}

/// Barra de status no rodape, como a do Internet Explorer 6.
class BarraStatusXp extends StatelessWidget {
  final String texto;
  final IconData icone;
  final String zona;

  const BarraStatusXp({
    super.key,
    required this.texto,
    this.icone = Icons.description_outlined,
    this.zona = 'Internet',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: CoresXp.bege,
        border: Border(top: BorderSide(color: CoresXp.begeEscuro, width: 2)),
      ),
      child: Row(
        children: [
          Icon(icone, size: 13, color: Colors.black54),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Container(width: 1, color: CoresXp.begeEscuro),
          const SizedBox(width: 6),
          const Icon(Icons.public, size: 13, color: CoresXp.azulSelecao),
          const SizedBox(width: 4),
          Text(zona, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

/// Barra de tarefas: botao "iniciar", janela aberta e bandeja com relogio.
class BarraTarefasXp extends StatelessWidget {
  final String tarefa;
  final IconData iconeTarefa;
  final bool redeDesconectada;

  const BarraTarefasXp({
    super.key,
    required this.tarefa,
    this.iconeTarefa = Icons.language,
    this.redeDesconectada = false,
  });

  @override
  Widget build(BuildContext context) {
    final agora = TimeOfDay.now();
    final relogio =
        '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}';

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.1, 0.5, 1.0],
          colors: [
            Color(0xFF3C81F3),
            CoresXp.azulBarraTarefas,
            Color(0xFF1F53D0),
            Color(0xFF1941A5),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 34,
          child: Row(
            children: [
              const _BotaoIniciar(),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  height: 26,
                  constraints: const BoxConstraints(maxWidth: 190),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4FC2),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: const Color(0xFF0F2F8A)),
                  ),
                  child: Row(
                    children: [
                      Icon(iconeTarefa, size: 15, color: Colors.white),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          tarefa,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _Bandeja(relogio: relogio, redeDesconectada: redeDesconectada),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoIniciar extends StatelessWidget {
  const _BotaoIniciar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.only(left: 10, right: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.15, 0.6, 1.0],
          colors: [
            Color(0xFF7ED17E),
            Color(0xFF49A949),
            CoresXp.verdeIniciar,
            Color(0xFF2B7A2B),
          ],
        ),
        boxShadow: [BoxShadow(color: Color(0x66000000), offset: Offset(2, 0))],
      ),
      child: const Row(
        children: [
          BandeiraXp(),
          SizedBox(width: 6),
          Text(
            'iniciar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              shadows: [Shadow(offset: Offset(1, 1), color: Color(0x99000000))],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeira de quatro cores desenhada com quadradinhos levemente inclinados.
class BandeiraXp extends StatelessWidget {
  const BandeiraXp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget quadrado(Color cor) => Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );

    return Transform.rotate(
      angle: -0.12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              quadrado(const Color(0xFFF65314)),
              quadrado(const Color(0xFF7CBB00)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              quadrado(const Color(0xFF00A1F1)),
              quadrado(const Color(0xFFFFBB00)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bandeja extends StatelessWidget {
  final String relogio;
  final bool redeDesconectada;

  const _Bandeja({required this.relogio, required this.redeDesconectada});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1290E8), CoresXp.azulBandeja, Color(0xFF0B77D1)],
        ),
        border: Border(left: BorderSide(color: Color(0xFF0B5AB8))),
      ),
      child: Row(
        children: [
          // Icone de rede com o "X" vermelho de cabo desconectado.
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.lan, size: 16, color: Colors.white),
              if (redeDesconectada)
                const Positioned(
                  right: -4,
                  bottom: -4,
                  child: Icon(
                    Icons.cancel,
                    size: 11,
                    color: CoresXp.vermelhoFechar,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.volume_up, size: 16, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            relogio,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Papel de parede "Bliss": ceu azul, nuvens e a colina verde.
class DesktopBliss extends StatelessWidget {
  final Widget child;

  const DesktopBliss({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand: o body do Scaffold tem restricoes folgadas e o
    // papel de parede precisa cobrir a tela toda, nao so o conteudo.
    return CustomPaint(
      painter: _BlissPainter(),
      child: SizedBox.expand(child: child),
    );
  }
}

class _BlissPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final retangulo = Offset.zero & size;

    canvas.drawRect(
      retangulo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A6FD6), Color(0xFF6FAEF0), Color(0xFFBFDDF8)],
        ).createShader(retangulo),
    );

    // Nuvens: elipses brancas desfocadas.
    final nuvem = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    for (final (x, y, largura) in [
      (0.15, 0.10, 0.45),
      (0.70, 0.18, 0.55),
      (0.35, 0.30, 0.35),
      (0.90, 0.40, 0.30),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * x, h * y),
          width: w * largura,
          height: w * largura * 0.28,
        ),
        nuvem,
      );
    }

    // Colina principal.
    final colina = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.38, h * 0.44, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final areaColina = Rect.fromLTWH(0, h * 0.44, w, h * 0.56);
    canvas.drawPath(
      colina,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7CC444), Color(0xFF4E9A2A), Color(0xFF2F6E1A)],
        ).createShader(areaColina),
    );

    // Colina do fundo, mais escura, aparecendo a direita.
    final colinaFundo = Path()
      ..moveTo(w * 0.55, h * 0.66)
      ..quadraticBezierTo(w * 0.85, h * 0.55, w, h * 0.60)
      ..lineTo(w, h * 0.68)
      ..close();
    canvas.drawPath(colinaFundo, Paint()..color = const Color(0xFF5DA634));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Icone da area de trabalho com o rotulo de sombra preta.
class IconeDesktopXp extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final Color cor;

  const IconeDesktopXp({
    super.key,
    required this.icone,
    required this.rotulo,
    this.cor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Icon(
            icone,
            size: 34,
            color: cor,
            shadows: const [Shadow(offset: Offset(1, 2), blurRadius: 3)],
          ),
          const SizedBox(height: 4),
          Text(
            rotulo,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              shadows: [Shadow(offset: Offset(1, 1), color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de progresso de blocos verdes (estatica).
class BlocosProgressoXp extends StatelessWidget {
  final int preenchidos;
  final int total;

  const BlocosProgressoXp({super.key, this.preenchidos = 7, this.total = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: CoresXp.bordaCampo),
      ),
      child: Row(
        children: [
          for (var i = 0; i < total; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: i < preenchidos
                    ? const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFADE7AD),
                            Color(0xFF37C837),
                            Color(0xFF2EA32E),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// Placa de "em construcao", com as faixas amarelas e pretas.
class PlacaEmConstrucao extends StatelessWidget {
  const PlacaEmConstrucao({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 28,
      child: CustomPaint(
        painter: _FaixasPainter(),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            color: const Color(0xFFFFD800),
            child: const Text(
              'EM CONSTRUÇÃO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaixasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFD800),
    );
    final preto = Paint()..color = Colors.black;
    for (double x = -size.height; x < size.width; x += 16) {
      canvas.drawPath(
        Path()
          ..moveTo(x, size.height)
          ..lineTo(x + 8, size.height)
          ..lineTo(x + 8 + size.height, 0)
          ..lineTo(x + size.height, 0)
          ..close(),
        preto,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// O clipe assistente, com olhos e sobrancelhas.
class ClipeAssistente extends StatelessWidget {
  const ClipeAssistente({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 96,
      child: CustomPaint(painter: _ClipePainter()),
    );
  }
}

class _ClipePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final arame = Paint()
      ..color = const Color(0xFF8C96A0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final brilho = Paint()
      ..color = const Color(0xFFE8EEF4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final clipe = Path()
      ..moveTo(18, 70)
      ..lineTo(18, 22)
      ..arcToPoint(const Offset(42, 22), radius: const Radius.circular(12))
      ..lineTo(42, 80)
      ..arcToPoint(const Offset(24, 80), radius: const Radius.circular(9))
      ..lineTo(24, 34)
      ..arcToPoint(const Offset(36, 34), radius: const Radius.circular(6))
      ..lineTo(36, 70);
    canvas.drawPath(clipe, arame);
    canvas.drawPath(clipe, brilho);

    // Olhos.
    final branco = Paint()..color = Colors.white;
    final contorno = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final pupila = Paint()..color = Colors.black;
    for (final x in [21.0, 37.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 30), width: 12, height: 14),
        branco,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 30), width: 12, height: 14),
        contorno,
      );
      canvas.drawCircle(Offset(x + 1.5, 31), 2.6, pupila);
    }

    // Sobrancelhas arqueadas.
    final sobrancelha = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(15, 19), const Offset(25, 17), sobrancelha);
    canvas.drawLine(const Offset(33, 17), const Offset(43, 19), sobrancelha);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
