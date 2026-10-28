# Panelinha em Flutter (pelada-gestao-front-web)

Versão em Flutter do Panelinha: monta a lista da pelada, cadastra os jogadores e sorteia os times.
Roda na web e está preparada para Android, iOS e desktop.

[![CI](https://github.com/WallaksCardoso/pelada-gestao-front-web/actions/workflows/ci.yml/badge.svg)](https://github.com/WallaksCardoso/pelada-gestao-front-web/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3-informational)
![Dart](https://img.shields.io/badge/Dart-3.9-informational)
[![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-informational)](LICENSE)

## Sobre

Interface do sistema da pelada em microsserviços: o login e o cadastro de usuários usam o
[spring-jwt-auth](https://github.com/WallaksCardoso/spring-jwt-auth), e listas, jogadores e sorteios
usam o [pelada-gestao](https://github.com/WallaksCardoso/pelada-gestao). O token JWT fica guardado no
armazenamento seguro do dispositivo.

## Funcionalidades

- Login e cadastro de usuário
- Criação de listas (sorteios) e cadastro de jogadores, marcando goleiros
- Sorteio dos times Azul e Vermelho, com reservas
- Listas em andamento e listas fechadas
- Tema claro e escuro, lembrado entre as aberturas
- Avisos e indicador de carregamento

## Stack

- Flutter 3 e Dart 3.9
- `http` para a API REST
- `flutter_secure_storage` para o token e as preferências
- `provider` para o tema
- `intl` para datas
- Docker (build web servido pelo nginx) e GitHub Actions

## Como rodar

O jeito mais simples é subir o sistema inteiro (backends, banco, Kafka e esta interface) com o
Docker Compose do [pelada-gestao](https://github.com/WallaksCardoso/pelada-gestao#sistema-completo-com-docker-compose)
e abrir <http://localhost:3000>.

Para desenvolver a interface, com os backends já rodando, é preciso o Flutter 3 (canal estável):

```bash
flutter pub get
flutter run -d chrome
```

Os endereços dos backends ficam em `lib/config/config.dart`. O padrão é `http://localhost:8081`
(autenticação) e `http://localhost:8080` (pelada); para outros endereços, informe no build:

```bash
flutter build web --release --dart-define=API_AUTH=https://... --dart-define=API_PELADA=https://...
```

## Testes

```bash
flutter test
```

Conferem que o app abre na tela de login e que o tema escolhido fica salvo. A CI roda a análise
estática, os testes e o build web a cada push, e monta a imagem Docker.

## Estrutura

```
lib/
  main.dart          rotas e tema
  config/            endereços dos backends
  core/              tema e utilidades (avisos, carregamento, cabeçalhos com token)
  features/
    auth/            login
    cadastro/        usuário, lista e jogadores
    sorteios/        listas em andamento e fechadas
  home/              tela inicial
Dockerfile           build web servido pelo nginx
```

## Projetos relacionados

- [pelada-gestao](https://github.com/WallaksCardoso/pelada-gestao): API de listas, jogadores e sorteio
- [spring-jwt-auth](https://github.com/WallaksCardoso/spring-jwt-auth): login e cadastro de usuários

## Licença

[MIT](LICENSE)
