import 'package:flutter/material.dart';

import '../models/noticia_model.dart';
import '../services/noticia_service.dart';
import '../theme/tema_xp.dart';

class DetalheNoticiaScreen extends StatelessWidget {
  final NoticiaModel noticia;

  const DetalheNoticiaScreen({super.key, required this.noticia});

  @override
  Widget build(BuildContext context) {
    final nomeArquivo = 'noticia_${noticia.id}.txt';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Notícia'),
        flexibleSpace: const FundoBarraTituloXp(),
        actions: const [BotoesJanelaXp(), SizedBox(width: 6)],
      ),
      bottomNavigationBar: BarraTarefasXp(
        tarefa: '$nomeArquivo - Bloco de notas',
        iconeTarefa: Icons.description,
      ),
      body: DesktopBliss(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  IconeDesktopXp(
                    icone: Icons.computer,
                    rotulo: 'Meu computador',
                  ),
                  IconeDesktopXp(
                    icone: Icons.folder,
                    rotulo: 'Meus documentos',
                    cor: Color(0xFFF5D372),
                  ),
                  IconeDesktopXp(
                    icone: Icons.delete_outline,
                    rotulo: 'Lixeira',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              JanelaXp(
                titulo: '$nomeArquivo - Bloco de notas',
                icone: Icons.description,
                menus: const [
                  'Arquivo',
                  'Editar',
                  'Formatar',
                  'Exibir',
                  'Ajuda',
                ],
                padding: EdgeInsets.zero,
                rodape: const BarraStatusXp(
                  texto: 'Ln 1, Col 1',
                  icone: Icons.edit_note,
                  zona: 'Somente leitura',
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: CoresXp.bordaCampo),
                      bottom: BorderSide(color: CoresXp.bordaCampo),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noticia.titulo,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: CoresXp.azulLink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Notícia #${noticia.id} · Autor ID ${noticia.autorId}',
                        style: textTheme.bodySmall,
                      ),
                      const Divider(height: 28),
                      Text(
                        noticia.resumo,
                        style: const TextStyle(
                          fontFamily: fonteBlocoDeNotas,
                          fontFamilyFallback: fontesReservaBlocoDeNotas,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              JanelaXp(
                titulo: 'Propriedades de $nomeArquivo',
                icone: Icons.info_outline,
                child: _Propriedades(
                  noticia: noticia,
                  nomeArquivo: nomeArquivo,
                ),
              ),
              const SizedBox(height: 16),
              const _ClipeComDica(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aba "Geral" da janela de propriedades, com dados reais da noticia.
class _Propriedades extends StatelessWidget {
  final NoticiaModel noticia;
  final String nomeArquivo;

  const _Propriedades({required this.noticia, required this.nomeArquivo});

  @override
  Widget build(BuildContext context) {
    final palavras = noticia.resumo
        .split(RegExp(r'\s+'))
        .where((palavra) => palavra.isNotEmpty)
        .length;

    final linhas = <(String, String)>[
      ('Tipo de arquivo:', 'Documento de texto'),
      ('Local:', '${NoticiaService.urlBase}/${noticia.id}'),
      ('Tamanho:', '${noticia.resumo.length} bytes'),
      ('Palavras:', '$palavras'),
      ('Autor:', 'Autor ID ${noticia.autorId}'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aba "Geral" selecionada, com a borda laranja do XP.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFFFC83C), width: 3),
              left: BorderSide(color: CoresXp.bordaCampo),
              right: BorderSide(color: CoresXp.bordaCampo),
            ),
          ),
          child: const Text('Geral', style: TextStyle(fontSize: 12)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: CoresXp.bordaCampo),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description,
                    size: 32,
                    color: CoresXp.azulSelecao,
                  ),
                  const SizedBox(width: 10),
                  Text(nomeArquivo, style: const TextStyle(fontSize: 13)),
                ],
              ),
              const Divider(height: 20),
              for (final (rotulo, valor) in linhas)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 104,
                        child: Text(
                          rotulo,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          valor,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 20),
              const Row(
                children: [
                  Text('Atributos:', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 30),
                  Icon(Icons.check_box, size: 16, color: CoresXp.azulSelecao),
                  SizedBox(width: 4),
                  Text('Somente leitura', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// O clipe assistente com o balao de dica. Pode ser fechado.
class _ClipeComDica extends StatefulWidget {
  const _ClipeComDica();

  @override
  State<_ClipeComDica> createState() => _ClipeComDicaState();
}

class _ClipeComDicaState extends State<_ClipeComDica> {
  bool _visivel = true;

  @override
  Widget build(BuildContext context) {
    if (!_visivel) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CoresXp.amareloBalao,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black54),
              boxShadow: const [
                BoxShadow(color: Color(0x44000000), offset: Offset(2, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parece que você está lendo uma notícia.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text('Deseja ajuda?', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                _OpcaoDica(
                  texto: 'Apenas ler a notícia sem ajuda',
                  onTap: () => setState(() => _visivel = false),
                ),
                _OpcaoDica(
                  texto: 'Não mostrar esta dica novamente',
                  onTap: () => setState(() => _visivel = false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        const ClipeAssistente(),
      ],
    );
  }
}

class _OpcaoDica extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;

  const _OpcaoDica({required this.texto, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 8, color: CoresXp.azulSelecao),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 12,
                  color: CoresXp.azulLink,
                  decoration: TextDecoration.underline,
                  decorationColor: CoresXp.azulLink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
