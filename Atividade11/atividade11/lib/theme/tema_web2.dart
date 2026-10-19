import 'dart:math';

import 'package:flutter/material.dart';

/// Paleta "Web 2.0" / Mac OS X Aqua (2005-2007): azul aqua brilhante,
/// verde-limao, laranja RSS, rosa e cinzas de metal escovado.
class CoresWeb2 {
  static const aqua = Color(0xFF2F8FE8);
  static const aquaClaro = Color(0xFF9FD3FF);
  static const aquaEscuro = Color(0xFF1C64C4);
  static const lima = Color(0xFF8DC63F);
  static const laranja = Color(0xFFF7831E);
  static const rosa = Color(0xFFFF0084);
  static const amarelo = Color(0xFFFFC20E);
  static const texto = Color(0xFF2B2B2B);
  static const textoSuave = Color(0xFF6B6B6B);
  static const borda = Color(0xFFD0D0D0);
  static const fundo = Color(0xFFF2F2F2);
}

const String fonteWeb2 = 'Lucida Grande';
const List<String> fontesReservaWeb2 = [
  'Lucida Sans Unicode',
  'Trebuchet MS',
  'Helvetica',
  'Arial',
];

/// Cores usadas para variar tags e avatares.
const List<Color> paletaWeb2 = [
  CoresWeb2.aqua,
  CoresWeb2.lima,
  CoresWeb2.laranja,
  CoresWeb2.rosa,
  Color(0xFF7B5CD6),
  Color(0xFF14A89A),
];

ThemeData criarTemaWeb2() {
  final esquemaCores = ColorScheme.fromSeed(seedColor: CoresWeb2.aqua).copyWith(
    primary: CoresWeb2.aqua,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: CoresWeb2.texto,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquemaCores,
    fontFamily: fonteWeb2,
    fontFamilyFallback: fontesReservaWeb2,
    scaffoldBackgroundColor: CoresWeb2.fundo,
    appBarTheme: const AppBarThemeData(
      backgroundColor: Color(0xFFD6D6D6),
      foregroundColor: Color(0xFF3A3A3A),
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: Color(0xFF8C8C8C))),
      titleTextStyle: TextStyle(
        fontFamily: fonteWeb2,
        fontFamilyFallback: fontesReservaWeb2,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3A3A3A),
        // Texto "gravado" no metal: sombra branca logo abaixo.
        shadows: [Shadow(offset: Offset(0, 1), color: Colors.white)],
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: CoresWeb2.borda),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      titleTextStyle: TextStyle(
        fontFamily: fonteWeb2,
        fontFamilyFallback: fontesReservaWeb2,
        fontSize: 15,
        color: CoresWeb2.texto,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: fonteWeb2,
        fontFamilyFallback: fontesReservaWeb2,
        fontSize: 12,
        color: CoresWeb2.textoSuave,
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFFEAF5FD),
      side: BorderSide(color: Color(0xFF9CCBEA)),
      shape: StadiumBorder(),
      labelStyle: TextStyle(
        fontFamily: fonteWeb2,
        fontFamilyFallback: fontesReservaWeb2,
        color: CoresWeb2.aquaEscuro,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: CoresWeb2.aquaEscuro),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE2E2E2)),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: CoresWeb2.aqua,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xE6222222),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentTextStyle: const TextStyle(
        fontFamily: fonteWeb2,
        fontFamilyFallback: fontesReservaWeb2,
        color: Colors.white,
      ),
    ),
  );
}

/// Notificacao no estilo Growl: caixa escura translucida com icone e titulo.
SnackBar criarGrowl({
  required String titulo,
  required String mensagem,
  required IconData icone,
  Color cor = CoresWeb2.aqua,
}) {
  return SnackBar(
    content: Row(
      children: [
        BolhaBrilhante(
          cor: cor,
          tamanho: 34,
          child: Icon(icone, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(mensagem, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Fundo listrado (pinstripe) das janelas do Mac OS X.
class FundoPinstripe extends StatelessWidget {
  final Widget child;

  const FundoPinstripe({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand: o body do Scaffold tem restricoes folgadas e o
    // fundo precisa cobrir a tela toda, nao so o conteudo.
    return CustomPaint(
      painter: _PinstripePainter(),
      child: SizedBox.expand(child: child),
    );
  }
}

class _PinstripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = CoresWeb2.fundo);
    final listra = Paint()..color = const Color(0xFFFBFBFB);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), listra);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Metal escovado para a barra superior (degrade + riscos horizontais).
class FundoMetalEscovado extends StatelessWidget {
  const FundoMetalEscovado({super.key});

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand: no flexibleSpace as restricoes sao folgadas.
    return SizedBox.expand(child: CustomPaint(painter: _MetalPainter()));
  }
}

class _MetalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.drawRect(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F4F4), Color(0xFFDADADA), Color(0xFFBEBEBE)],
        ).createShader(area),
    );

    // Riscos finos e irregulares, como aluminio escovado.
    final aleatorio = Random(1984);
    final risco = Paint()..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 1) {
      final claro = aleatorio.nextBool();
      risco.color = (claro ? Colors.white : Colors.black).withValues(
        alpha: aleatorio.nextDouble() * (claro ? 0.35 : 0.05),
      );
      final inicio = aleatorio.nextDouble() * size.width * 0.5;
      final fim = inicio + size.width * (0.3 + aleatorio.nextDouble() * 0.7);
      canvas.drawLine(Offset(inicio, y), Offset(fim, y), risco);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Os tres botoes coloridos do canto da janela do Mac (decorativos).
class SemaforoAqua extends StatelessWidget {
  const SemaforoAqua({super.key});

  @override
  Widget build(BuildContext context) {
    Widget botao(Color cor) => Container(
      width: 13,
      height: 13,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.5),
          radius: 0.9,
          colors: [Color.lerp(cor, Colors.white, 0.6)!, cor],
        ),
        border: Border.all(color: Color.lerp(cor, Colors.black, 0.35)!),
      ),
    );

    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          botao(const Color(0xFFFF5F57)),
          botao(const Color(0xFFFEBC2E)),
          botao(const Color(0xFF28C840)),
        ],
      ),
    );
  }
}

/// Logotipo em minusculas com degrade e o indispensavel selo "beta".
class LogoWeb2 extends StatelessWidget {
  final String texto;

  const LogoWeb2({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (area) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6BC0FF), CoresWeb2.aquaEscuro],
          ).createShader(area),
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: Colors.white,
              shadows: [],
            ),
          ),
        ),
        const SizedBox(width: 3),
        Transform.rotate(
          angle: -0.2,
          child: Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFB347), CoresWeb2.laranja],
              ),
              border: Border.all(color: const Color(0xFFC95A07)),
            ),
            child: const Text(
              'beta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                shadows: [],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reflexo brilhante da metade de cima, o "gel" das interfaces Aqua.
class _Brilho extends StatelessWidget {
  final BorderRadius borderRadius;

  const _Brilho({required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botao em formato de pilula com aspecto de gel (Aqua).
class BotaoAqua extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final IconData? icone;
  final Color cor;

  const BotaoAqua({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
    this.cor = CoresWeb2.aqua,
  });

  @override
  Widget build(BuildContext context) {
    const formato = BorderRadius.all(Radius.circular(999));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: formato,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(cor, Colors.white, 0.45)!,
                cor,
                Color.lerp(cor, Colors.black, 0.15)!,
              ],
            ),
            border: Border.all(color: Color.lerp(cor, Colors.black, 0.35)!),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icone != null) ...[
                      Icon(icone, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            color: Color(0x66000000),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const _Brilho(borderRadius: formato),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circulo de gel brilhante (avatares, icones de notificacao).
class BolhaBrilhante extends StatelessWidget {
  final Color cor;
  final double tamanho;
  final Widget child;

  const BolhaBrilhante({
    super.key,
    required this.cor,
    required this.child,
    this.tamanho = 38,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(cor, Colors.white, 0.35)!, cor],
              ),
              border: Border.all(color: Color.lerp(cor, Colors.black, 0.3)!),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Center(child: child),
          ),
          Positioned(
            top: tamanho * 0.06,
            left: tamanho * 0.18,
            right: tamanho * 0.18,
            height: tamanho * 0.42,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(tamanho, tamanho * 0.5),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icone de RSS laranja e brilhante, simbolo maximo da Web 2.0.
class IconeRss extends StatelessWidget {
  final double tamanho;

  const IconeRss({super.key, this.tamanho = 28});

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(tamanho * 0.22);

    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: raio,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFB55C),
                  CoresWeb2.laranja,
                  Color(0xFFE0600A),
                ],
              ),
              border: Border.all(color: const Color(0xFFC95A07)),
            ),
            child: Center(
              child: Icon(
                Icons.rss_feed,
                color: Colors.white,
                size: tamanho * 0.68,
              ),
            ),
          ),
          _Brilho(borderRadius: raio),
        ],
      ),
    );
  }
}

/// Selo estrelado "NOVO!" (o famoso starburst).
class SeloNovo extends StatelessWidget {
  const SeloNovo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: CustomPaint(
        painter: _EstrelaPainter(),
        child: Center(
          child: Transform.rotate(
            angle: -0.3,
            child: const Text(
              'NOVO!',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFFB3261E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EstrelaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const pontas = 16;
    final centro = size.center(Offset.zero);
    final externo = size.width / 2;
    final interno = externo * 0.78;

    final estrela = Path();
    for (var i = 0; i < pontas * 2; i++) {
      final raio = i.isEven ? externo : interno;
      final angulo = i * pi / pontas;
      final ponto = centro + Offset(cos(angulo) * raio, sin(angulo) * raio);
      if (i == 0) {
        estrela.moveTo(ponto.dx, ponto.dy);
      } else {
        estrela.lineTo(ponto.dx, ponto.dy);
      }
    }
    estrela.close();

    canvas.drawShadow(estrela, Colors.black, 2, false);
    canvas.drawPath(
      estrela,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF59A), Color(0xFFFFC20E), Color(0xFFFF8A00)],
        ).createShader(Rect.fromCircle(center: centro, radius: externo)),
    );
    canvas.drawPath(
      estrela,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Caixa branca arredondada com sombra suave, base dos blocos de conteudo.
class CaixaWeb2 extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CaixaWeb2({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresWeb2.borda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }
}
