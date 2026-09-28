import 'package:flutter/material.dart';

import 'tela_resumo.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aula 7 - Navegação',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const TelaContador(),
    );
  }
}

class TelaContador extends StatefulWidget {
  const TelaContador({super.key});

  @override
  State<TelaContador> createState() => _TelaContadorState();
}

class _TelaContadorState extends State<TelaContador> {
  int _quantidade = 1;
  final String _nomeProduto = 'Smartphone Galaxy S24';
  static const double _precoUnitario = 150.00;

  void _incrementar() {
    setState(() {
      _quantidade++;
    });
  }

  void _decrementar() {
    setState(() {
      if (_quantidade > 1) {
        _quantidade--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double total = _quantidade * _precoUnitario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleção de Itens'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _nomeProduto,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Preço unitário: R\$ ${_precoUnitario.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: _decrementar,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '$_quantidade',
                    key: const Key('quantidade'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton.filledTonal(
                    onPressed: _incrementar,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => setState(() => _quantidade = 1),
                child: const Text('Zerar Contador'),
              ),
              const SizedBox(height: 24),
              Text(
                'Total: R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaResumo(
                        item: _nomeProduto,
                        quantidade: _quantidade,
                        total: total,
                      ),
                    ),
                  );
                },
                child: const Text('Avançar para Resumo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
