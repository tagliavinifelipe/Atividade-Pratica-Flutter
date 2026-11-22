import 'package:flutter/material.dart';

enum NivelPrecisao {
  alta('Precisão alta', Colors.green),
  media('Precisão média', Colors.amber),
  baixa('Precisão baixa', Colors.red);

  const NivelPrecisao(this.rotulo, this.cor);

  final String rotulo;
  final Color cor;
}

/// Classifica a precisão do GPS (em metros):
/// abaixo de 15 m é alta, de 15 a 50 m (inclusive) é média e acima de 50 m é baixa.
NivelPrecisao classificarPrecisao(double metros) {
  if (metros < 15) return NivelPrecisao.alta;
  if (metros <= 50) return NivelPrecisao.media;
  return NivelPrecisao.baixa;
}
