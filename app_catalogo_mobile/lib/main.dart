import 'package:flutter/material.dart';
import 'models/produto.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Produtos',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const TelaCatalogo(),
    );
  }
}

class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});

  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {
  // Simula o JSON que viria de uma API real
  final Map<String, dynamic> _jsonSimulado = const {
    "nome_produto": "Smartphone Galaxy S24",
    "categoria": "Mobile",
    "preco": 4599.90,
    "quantidade_estoque": 12,
    "disponivel": true,
    "tags": ["android", "5g", "snapdragon"],
  };

  late Produto _produto;

  @override
  void initState() {
    super.initState();
    _produto = Produto.fromJson(_jsonSimulado);
  }

  void _recarregar() {
    // Simula uma nova consulta à API, variando o estoque para
    // demonstrar o alerta de estoque crítico
    setState(() {
      final novoEstoque = _produto.quantidadeEstoque > 4 ? 3 : 12;
      _produto = Produto.fromJson({
        ..._jsonSimulado,
        "quantidade_estoque": novoEstoque,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _produto.nomeProduto,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _produto.categoria,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'R\$ ${_produto.preco.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: _produto.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (_produto.temEstoqueCritico)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Estoque crítico: apenas ${_produto.quantidadeEstoque} unidade(s) restante(s)!',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Em estoque: ${_produto.quantidadeEstoque} unidades',
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recarregar,
        child: const Icon(Icons.sync),
      ),
    );
  }
}