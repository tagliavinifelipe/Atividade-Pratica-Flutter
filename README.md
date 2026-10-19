# Atividade-Pratica-Flutter

<img width="605" height="915" alt="image" src="https://github.com/user-attachments/assets/811836c3-603e-4a49-bc83-d215a0dd10c6" />

## Aula 10 - Consumo avançado de APIs, listas e exceções

Feed de notícias que consome `https://jsonplaceholder.typicode.com/posts` com o pacote `http`.
A tela trata os quatro estados: carregando, erro (com botão "Tentar Novamente"), vazio e sucesso (`ListView.builder` com cards).
O serviço separa erro de rede ("Falha ao conectar com a API") de erro de status HTTP ("Status HTTP de erro: <código>").

Desafios feitos:

- **Básico:** filtro local por título, em tempo real e sem diferenciar maiúsculas/minúsculas.
- **Intermediário:** tela de detalhes (`DetalheNoticiaScreen`) com o texto completo, aberta com `Navigator.push`.
- **Avançado:** botão na AppBar que simula erro de conexão (URL inexistente), com ícone vermelho e `SnackBar` indicando o modo.

Como rodar:

```bash
cd Atividade10/atividade10 && flutter pub get && flutter run
flutter test
```

## Aula 11 - Fluxo Lista/Detalhe (Master-Detail)

Lista de notícias com `FutureBuilder` (loading, erro, vazio e dados). Ao tocar em um card, o objeto já carregado é passado para a tela de detalhes via `Navigator.push`, sem nova requisição.
O detalhe mostra imagem de capa, autor (`Chip`), título e conteúdo completo.

Desafios feitos:

- **Básico:** Hero animation entre a miniatura do card e a imagem de capa do detalhe.
- **Intermediário:** botão de favoritar no detalhe que devolve o resultado com `Navigator.pop`; o feed mostra um coração no card favorito e uma `SnackBar`.
- **Avançado:** comentários da notícia (`/posts/{id}/comments`) carregados na tela de detalhes.

Como rodar:

```bash
cd Atividade11/atividade11 && flutter pub get && flutter run
flutter test
```

