# Contador App — Aula 6 (Desafios de Laboratório)

Resolve os três níveis do slide "Desafios de Laboratório (Mão na Massa)":

- **Nível 1 (Básico):** botão `OutlinedButton` de **Reset** na `Column` que força `_contador` de volta a zero.
- **Nível 2 (Intermediário):** `TextStyle.color` muda dinamicamente — pares em **azul**, ímpares em **vermelho**.
- **Nível 3 (Avançado):** contador trava em **10**. Ao atingir o limite, o `FloatingActionButton` recebe `onPressed: null` e fica visualmente desativado.

Também mantém a funcionalidade base da aula: toggle de tema Light/Dark via `IconButton` na `AppBar`.

## Como rodar

Este zip contém só o essencial (`lib/`, `test/`, `pubspec.yaml`). As pastas de plataforma (`android/`, `ios/`, `web/`, etc.) são geradas pelo Flutter localmente. Passo a passo:

```bash
# 1. Descompactar
unzip contador_app.zip
cd contador_app

# 2. Gerar as pastas de plataforma que faltam (mantém o lib/ e o pubspec)
flutter create .

# 3. Baixar dependências
flutter pub get

# 4. Rodar no emulador ou dispositivo
flutter run
```

## Testes

```bash
flutter test
```

Cobre os três níveis: Reset zera, cor alterna por paridade, FAB desativa em 10.

## Estrutura

```
contador_app/
├── lib/
│   └── main.dart          # App inteiro, com os 3 níveis marcados por comentário
├── test/
│   └── widget_test.dart   # Um teste por nível
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```
