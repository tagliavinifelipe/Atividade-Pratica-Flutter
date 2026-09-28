import 'package:flutter/material.dart';

import '../models/produto.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback? onTap;

  const ProdutoCard({super.key, required this.produto, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(produto.icone, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          produto.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Categoria: ${produto.categoria}'),
        trailing: Text(
          'R\$ ${produto.preco.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
