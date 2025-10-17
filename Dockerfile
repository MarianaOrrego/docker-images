# Stage 1: Assets
FROM alpine:latest AS assets
COPY assets/ /assets/

# Stage 2: Builder
FROM gradle:8.10-jdk21 AS builder

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    jq \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copiar assets de Bancolombia
COPY --from=assets /assets /assets

# Usar el usuario gradle que ya viene en la imagen (UID 1000)
# En lugar de crear uno nuevo
USER root

# Crear directorios de trabajo
RUN mkdir -p /workspace /app/results && \
    chown -R gradle:gradle /workspace /app /assets

# Copiar script de scaffolding
COPY src/java-template-tester/java-template-test.sh /workspace/
RUN chmod +x /workspace/java-template-test.sh && \
    chown gradle:gradle /workspace/java-template-test.sh

# Cambiar a usuario no-root (gradle ya existe en la imagen)
USER gradle
WORKDIR /workspace

# Variables de entorno
ENV JAVA_HOME=/opt/java/openjdk
ENV GRADLE_HOME=/opt/gradle
ENV PATH=$JAVA_HOME/bin:$GRADLE_HOME/bin:$PATH

ENTRYPOINT ["/workspace/java-template-test.sh"]