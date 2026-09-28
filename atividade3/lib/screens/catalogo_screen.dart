import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../widgets/produto_card.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final List<Produto> _produtos = [
    const Produto(
      id: 1,
      nome: 'Smartphone',
      preco: 1899.90,
      categoria: 'Eletrônicos',
      icone: '📱',
    ),
    const Produto(
      id: 2,
      nome: 'Notebook',
      preco: 3499.00,
      categoria: 'Informática',
      icone: '💻',
    ),
    const Produto(
      id: 3,
      nome: 'Fone de Ouvido',
      preco: 249.90,
      categoria: 'Áudio',
      icone: '🎧',
    ),
    const Produto(
      id: 4,
      nome: 'Smartwatch',
      preco: 899.90,
      categoria: 'Acessórios',
      icone: '⌚',
    ),
    const Produto(
      id: 5,
      nome: 'Teclado',
      preco: 399.90,
      categoria: 'Periféricos',
      icone: '⌨️',
    ),
  ];

  int _proximoId = 6;

  void _adicionarProduto() {
    setState(() {
      _produtos.add(
        Produto(
          id: _proximoId,
          nome: 'Novo Produto $_proximoId',
          preco: 99.90,
          categoria: 'Diversos',
          icone: '🆕',
        ),
      );
      _proximoId++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Itens: ${_produtos.length}')),
          ),
        ],
      ),
      body: _produtos.isEmpty
          ? const Center(child: Text('Nenhum produto no catálogo'))
          : ListView.builder(
              itemCount: _produtos.length,
              itemBuilder: (context, index) {
                final produto = _produtos[index];
                return Dismissible(
                  key: ValueKey(produto.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.only(right: 16),
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() => _produtos.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${produto.nome} removido')),
                    );
                  },
                  child: ProdutoCard(
                    produto: produto,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${produto.nome} selecionado')),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarProduto,
        tooltip: 'Adicionar produto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
