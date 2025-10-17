# ═══════════════════════════════════════════════════════════════
# KAIZEN - BANCOLOMBIA INTERNAL DEVELOPER PORTAL
# Java Clean Architecture Scaffolding Image
# ═══════════════════════════════════════════════════════════════

# Stage 1: Assets - Contiene los archivos de configuración de Bancolombia
FROM alpine:latest AS assets
COPY assets/ /assets/

# Stage 2: Builder - Imagen principal con Gradle y Java
FROM gradle:8.10-jdk21 AS builder

# Instalar dependencias del sistema necesarias para scaffolding
RUN apt-get update && apt-get install -y \
    jq \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copiar assets de Bancolombia desde el stage anterior
COPY --from=assets /assets /assets

# Configuración de usuario no-root (compliance Bancolombia)
RUN groupadd -g 2000 appgroup && \
    useradd -u 1000 -g appgroup -m -s /bin/bash appuser

# Crear directorios de trabajo
RUN mkdir -p /workspace /app/results && \
    chown -R appuser:appgroup /workspace /app

# Copiar script de scaffolding
COPY src/java-template-tester/java-template-test.sh /workspace/java-template-test.sh
RUN chmod +x /workspace/java-template-test.sh && \
    chown appuser:appgroup /workspace/java-template-test.sh

# Cambiar a usuario no-root
USER appuser
WORKDIR /workspace

# Variables de entorno
ENV JAVA_HOME=/opt/java/openjdk
ENV GRADLE_HOME=/opt/gradle
ENV PATH=$JAVA_HOME/bin:$GRADLE_HOME/bin:$PATH
ENV WORKSPACE_DIR=/workspace
ENV RESULTS_DIR=/app/results

# Variables por defecto para scaffolding
ENV PROJECT_NAME=demo-app
ENV PACKAGE=com.bancolombia
ENV TYPE=reactive
ENV LOMBOK=true
ENV METRICS=true
ENV MUTATION=true
ENV JAVA_VERSION=VERSION_21

# Health check para Kubernetes
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s \
    CMD test -f "$RESULTS_DIR/scaffold_status" || exit 1

# Labels para identificación en Kaizen
LABEL maintainer="Kaizen Team - Bancolombia IDP" \
      purpose="Java Clean Architecture Scaffolding" \
      template-type="java-clean-architecture" \
      gradle-version="8.10" \
      java-version="21" \
      plugin-version="3.23.0" \
      environment="production"

ENTRYPOINT ["/workspace/java-template-test.sh"]
