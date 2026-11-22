import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

class GeolocalizacaoScreen extends StatefulWidget {
  GeolocalizacaoScreen({super.key, LocationService? locationService})
    : locationService = locationService ?? LocationService();

  final LocationService locationService;

  @override
  State<GeolocalizacaoScreen> createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen> {
  Position? _posicaoAtual;
  String? _mensagemErro;
  bool _carregando = false;
  bool _rastreando = false;
  StreamSubscription<Position>? _assinaturaPosicao;

  String _formatarErro(Object erro) {
    return erro.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _buscarLocalizacao() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final Position posicao = await widget.locationService.obterPosicaoAtual();
      if (!mounted) return;
      setState(() {
        _posicaoAtual = posicao;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _mensagemErro = _formatarErro(erro);
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _alternarRastreamento() {
    if (_rastreando) {
      _assinaturaPosicao?.cancel();
      _assinaturaPosicao = null;
      setState(() {
        _rastreando = false;
      });
      return;
    }

    setState(() {
      _rastreando = true;
      _mensagemErro = null;
    });

    _assinaturaPosicao = widget.locationService.monitorarPosicao().listen(
      (Position posicao) {
        if (!mounted) return;
        setState(() {
          _posicaoAtual = posicao;
        });
      },
      onError: (Object erro) {
        _assinaturaPosicao?.cancel();
        _assinaturaPosicao = null;
        if (!mounted) return;
        setState(() {
          _rastreando = false;
          _mensagemErro = _formatarErro(erro);
        });
      },
    );
  }

  @override
  void dispose() {
    _assinaturaPosicao?.cancel();
    super.dispose();
  }

  Widget _linhaInformacao(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(valor, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Position? posicao = _posicaoAtual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in & GPS'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.location_on, size: 80, color: Colors.lightBlue),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coordenadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _linhaInformacao(
                      'Latitude:',
                      posicao?.latitude.toStringAsFixed(6) ?? '--',
                    ),
                    _linhaInformacao(
                      'Longitude:',
                      posicao?.longitude.toStringAsFixed(6) ?? '--',
                    ),
                    _linhaInformacao(
                      'Precisão:',
                      posicao != null
                          ? '${posicao.accuracy.toStringAsFixed(1)} m'
                          : '--',
                    ),
                    _linhaInformacao(
                      'Altitude:',
                      posicao != null
                          ? '${posicao.altitude.toStringAsFixed(1)} m'
                          : '--',
                    ),
                  ],
                ),
              ),
            ),
            if (_mensagemErro != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _mensagemErro!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _buscarLocalizacao,
              icon: _carregando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Capturar Localização Atual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _alternarRastreamento,
              icon: Icon(_rastreando ? Icons.stop : Icons.play_arrow),
              label: Text(
                _rastreando ? 'Parar Rastreamento' : 'Iniciar Rastreamento',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _rastreando ? Colors.red : Colors.lightBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
