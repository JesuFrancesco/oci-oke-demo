FROM debian:stable-slim AS build

# Dependencias
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Descargar Flutter estable (última versión compatible con Dart >= 3.8)
RUN curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.2-stable.tar.xz \
    -o flutter.tar.xz \
 && tar xf flutter.tar.xz -C /usr/local \
 && rm flutter.tar.xz

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Evitar error de Git "dubious ownership"
RUN git config --global --add safe.directory /usr/local/flutter

RUN flutter config --enable-web

# Actualizar Flutter al último stable disponible (importante)
RUN flutter upgrade

WORKDIR /app

COPY . .

# Ejecutar pub get con el nuevo Dart 3.8+
RUN flutter pub get

# Build web
RUN flutter build web

# Etapa final: Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
