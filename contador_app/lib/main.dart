// Aula 6 - Desafios de Laboratório (Mão na Massa)
// Resolve os 3 níveis: Reset, cor dinâmica por paridade, e trava em 10.

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Fundações da aula: as duas variáveis vitais do app.
  int _contador = 0;
  bool _isDark = false;

  // Limite do Nível 3: quando _contador chegar aqui, o FAB é desativado.
  static const int _limite = 10;

  void _incrementar() {
    setState(() {
      // Nível 3 (defesa em profundidade): mesmo que onPressed seja null
      // quando bate no limite, guardamos aqui também.
      if (_contador < _limite) _contador++;
    });
  }

  void _resetar() {
    // Nível 1 — força o contador de volta a zero.
    setState(() => _contador = 0);
  }

  void _alternarTema() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    // Nível 2 — cor dinâmica conforme a paridade do contador.
    // Pares -> tons de azul. Ímpares -> vermelho.
    // Zero conta como par (fica azul).
    final Color corDoNumero =
        _contador.isEven ? Colors.blue.shade700 : Colors.red.shade600;

    // Nível 3 — se atingiu o limite, onPressed vira null e o FAB
    // fica visualmente desativado (cinza, sem splash).
    final VoidCallback? acaoDoFab =
        _contador >= _limite ? null : _incrementar;

    return MaterialApp(
      title: 'Contador Aula 6',
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Contador'),
          actions: [
            IconButton(
              icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Alternar tema',
              onPressed: _alternarTema,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Cliques:'),
              const SizedBox(height: 8),
              Text(
                '$_contador',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: corDoNumero, // <- Nível 2 aplicado aqui
                ),
              ),
              const SizedBox(height: 24),
              // Nível 1 — botão Reset.
              OutlinedButton.icon(
                onPressed: _resetar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              if (_contador >= _limite) ...[
                const SizedBox(height: 16),
                Text(
                  'Limite atingido ($_limite). Use Reset para continuar.',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ],
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: acaoDoFab, // null quando >= 10  -> desabilitado
          tooltip: 'Incrementar',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
