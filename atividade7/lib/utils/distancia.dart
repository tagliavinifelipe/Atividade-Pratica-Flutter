/// Formata uma distância em metros: abaixo de 1000 m mostra em metros
/// (ex.: "850 m"); a partir disso, em km com 2 casas e vírgula (ex.: "3,42 km").
String formatarDistancia(double metros) {
  final int metrosArredondados = metros.round();
  if (metrosArredondados < 1000) {
    return '$metrosArredondados m';
  }
  final String km = (metros / 1000).toStringAsFixed(2).replaceAll('.', ',');
  return '$km km';
}
