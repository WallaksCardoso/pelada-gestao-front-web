# pelada-gestao-front-web

[![CI](https://github.com/WallaksCardoso/pelada-gestao-front-web/actions/workflows/ci.yml/badge.svg)](https://github.com/WallaksCardoso/pelada-gestao-front-web/actions/workflows/ci.yml)

Panelinha, a tela do sistema da pelada, em Flutter. Monta a lista da semana, cadastra quem vai jogar
e sorteia os times. Fala com o [spring-jwt-auth](https://github.com/WallaksCardoso/spring-jwt-auth)
para o login e com o [pelada-gestao](https://github.com/WallaksCardoso/pelada-gestao) para o resto.

![Resultado do sorteio](docs/img/resultado.png)

Escrevi uma primeira versão em JavaScript puro e reescrevi em Flutter para aprender o framework e
ter a mesma tela na web e no celular.

O resultado sai com os times lado a lado e um botão que copia o texto pronto para colar no grupo:

```
Pelada de quinta - 30/10/2026

Time Azul
- Bruno (goleiro)
- Ana
...
```

## Rodando

O jeito mais simples é o Docker Compose do
[pelada-gestao](https://github.com/WallaksCardoso/pelada-gestao#subindo-tudo), que sobe os backends e
esta tela em <http://localhost:3000>.

Para mexer na interface, com os backends rodando e o Flutter 3 instalado:

```bash
flutter pub get
flutter run -d chrome
```

Por padrão ela procura a autenticação em `localhost:8081` e a API em `localhost:8080`. Para outros
endereços:

```bash
flutter build web --release --dart-define=API_AUTH=https://... --dart-define=API_PELADA=https://...
```

## Testes

```bash
flutter test
```

Cobrem o login, a ida para a criação de conta, o aviso de campos vazios, o tema (escuro por padrão e
lembrado entre as aberturas) e o texto do resultado. A CI também roda `flutter analyze` e monta a
imagem Docker.

## Licença

MIT
