import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> obterPosicaoAtual() async {
    bool servicoHabilitado;
    LocationPermission permissao;

    servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      throw Exception('O serviço de GPS está desativado no dispositivo.');
    }

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw Exception('Permissão de localização negada pelo usuário.');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'Permissões negadas permanentemente. Altere nas configurações.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Stream<Position> monitorarPosicao() {
    const LocationSettings configuracoes = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: configuracoes);
  }
}
