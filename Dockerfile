# ═══════════════════════════════════════════════════════════════
# KAIZEN - BANCOLOMBIA INTERNAL DEVELOPER PORTAL
# Java Clean Architecture Scaffolding Image v2.1
# Fixed: Auto-download with READY_FOR_DOWNLOAD signal
# ═══════════════════════════════════════════════════════════════

# Stage 1: Assets - Contiene los archivos de configuración de Bancolombia
FROM alpine:latest AS assets
COPY assets/ /assets/

# Stage 2: Main - Imagen principal con Gradle y Java
FROM gradle:8.10-jdk21

# Instalar dependencias del sistema necesarias para scaffolding
RUN apt-get update && apt-get install -y \
    jq \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copiar assets de Bancolombia desde el stage anterior
COPY --from=assets /assets /assets

# Trabajar como root temporalmente para configurar
USER root

# Crear directorios de trabajo con permisos correctos
RUN mkdir -p /workspace /app/results /opt/kaizen && \
    chown -R gradle:gradle /workspace /app /assets /opt/kaizen

# Copiar script de scaffolding a /opt/kaizen (NO a /workspace porque se monta un volumen ahí)
COPY src/java-template-tester/java-template-test.sh /opt/kaizen/java-template-test.sh
RUN chmod +x /opt/kaizen/java-template-test.sh && \
    chown gradle:gradle /opt/kaizen/java-template-test.sh

# Cambiar a usuario no-root (gradle ya existe en la imagen con UID 1000)
USER gradle
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

ENTRYPOINT ["/bin/bash", "/opt/kaizen/java-template-test.sh"]
