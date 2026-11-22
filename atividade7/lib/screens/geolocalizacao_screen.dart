import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/location_service.dart';
import '../utils/constantes.dart';
import '../utils/distancia.dart';
import '../utils/precisao.dart';

class GeolocalizacaoScreen extends StatefulWidget {
  const GeolocalizacaoScreen({super.key, this.locationService});

  /// Permite injetar um serviço falso nos testes. Se for nulo, usa o real.
  final LocationService? locationService;

  @override
  State<GeolocalizacaoScreen> createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen> {
  late final LocationService _locationService =
      widget.locationService ?? LocationService();
  Position? _posicaoAtual;
  bool _carregando = false;
  String? _mensagemErro;
  StreamSubscription<Position>? _positionStreamSub;
  bool _rastreando = false;

  Future<void> _buscarLocalizacao() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });
    try {
      final posicao = await _locationService.obterPosicaoAtual();
      if (!mounted) return;
      setState(() => _posicaoAtual = posicao);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _mensagemErro = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _alternarRastreamento() {
    if (_rastreando) {
      _positionStreamSub?.cancel();
      _positionStreamSub = null;
      setState(() => _rastreando = false);
    } else {
      setState(() {
        _rastreando = true;
        _mensagemErro = null;
      });
      _positionStreamSub = _locationService.monitorarPosicao().listen(
        (pos) {
          if (!mounted) return;
          setState(() => _posicaoAtual = pos);
        },
        onError: (Object err) {
          _positionStreamSub?.cancel();
          _positionStreamSub = null;
          if (!mounted) return;
          setState(() {
            _rastreando = false;
            _mensagemErro = err.toString().replaceAll('Exception: ', '');
          });
        },
      );
    }
  }

  // Desafio avançado: abre a posição atual no Google Maps.
  Future<void> _abrirNoMapa(Position posicao) async {
    final Uri url = Uri.parse(
      'https://maps.google.com/?q=${posicao.latitude},${posicao.longitude}',
    );

    bool abriu;
    try {
      abriu = await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      abriu = false;
    }

    if (!abriu && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o mapa neste dispositivo.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  // Desafio básico: Chip verde/amarelo/vermelho conforme a precisão.
  Widget _chipPrecisao(double metros) {
    final NivelPrecisao nivel = classificarPrecisao(metros);
    return Chip(
      avatar: Icon(Icons.gps_fixed, color: nivel.cor, size: 18),
      label: Text('${nivel.rotulo} (${metros.toStringAsFixed(1)} m)'),
      backgroundColor: nivel.cor.withValues(alpha: 0.2),
      side: BorderSide(color: nivel.cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Position? posicao = _posicaoAtual;

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in & GPS'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ocupa o espaço do Spacer do roteiro, mas rola se o conteúdo
            // (com os desafios) não couber na tela.
            Expanded(
              child: ListView(
                children: [
                  if (_carregando)
                    const Center(child: CircularProgressIndicator()),
                  if (_mensagemErro != null)
                    Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _mensagemErro!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  if (posicao != null) ...[
                    Card(
                      elevation: 3,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                            ),
                            title: const Text('Latitude'),
                            subtitle: Text('${posicao.latitude}'),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                            ),
                            title: const Text('Longitude'),
                            subtitle: Text('${posicao.longitude}'),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.speed,
                              color: Colors.orange,
                            ),
                            title: const Text('Precisão / Altitude'),
                            subtitle: Text(
                              'Precisão: ${posicao.accuracy.toStringAsFixed(1)}m | '
                              'Alt: ${posicao.altitude.toStringAsFixed(1)}m',
                            ),
                          ),
                          // Desafio intermediário: distância até a Fatec.
                          ListTile(
                            leading: const Icon(
                              Icons.school,
                              color: Colors.purple,
                            ),
                            title: const Text('Distância até a Fatec Matão'),
                            subtitle: Text(
                              formatarDistancia(
                                Geolocator.distanceBetween(
                                  posicao.latitude,
                                  posicao.longitude,
                                  kLatitudeFatec,
                                  kLongitudeFatec,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(child: _chipPrecisao(posicao.accuracy)),
                  ],
                ],
              ),
            ),
            if (posicao != null) ...[
              ElevatedButton.icon(
                onPressed: () => _abrirNoMapa(posicao),
                icon: const Icon(Icons.map),
                label: const Text('Abrir no Mapa'),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton.icon(
              onPressed: _carregando ? null : _buscarLocalizacao,
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Capturar Localização Atual'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _alternarRastreamento,
              icon: Icon(_rastreando ? Icons.stop : Icons.play_arrow),
              label: Text(
                _rastreando
                    ? 'Parar Rastreamento'
                    : 'Iniciar Rastreamento Contínuo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
