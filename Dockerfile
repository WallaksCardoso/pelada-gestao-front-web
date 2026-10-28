FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
ARG API_AUTH=http://localhost:8081
ARG API_PELADA=http://localhost:8080
RUN flutter build web --release \
    --dart-define=API_AUTH=${API_AUTH} \
    --dart-define=API_PELADA=${API_PELADA}

FROM nginx:1.27-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
