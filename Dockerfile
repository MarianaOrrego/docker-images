FROM public.ecr.aws/amazoncorretto/amazoncorretto:17

# Configurar yum para bypass SSL en entorno corporativo Bancolombia
RUN echo "sslverify=false" >> /etc/yum.conf && \
    echo "timeout=300" >> /etc/yum.conf

# Instalar herramientas necesarias para Kaizen template testing
RUN yum update -y && yum install -y \
    curl \
    wget \
    git \
    unzip \
    awscli \
    jq \
    tar \
    && yum clean all

# Crear usuario no-root para seguridad
RUN useradd -m -u 1001 -s /bin/bash kaizen-tester
USER kaizen-tester
WORKDIR /workspace

# Copia de scripts
COPY --chown=kaizen-tester:kaizen-tester src/java-template-tester/java-template-test.sh /workspace/java-template-test.sh
RUN chmod +x /workspace/java-template-test.sh

# Variables de entorno para Kaizen en AWS
ENV AWS_DEFAULT_REGION=us-east-2
ENV WORKSPACE_DIR=/workspace
ENV RESULTS_DIR=/workspace/results
ENV KAIZEN_ENV=sandbox
ENV BANCOLOMBIA_IDP=kaizen

# Crear directorios necesarios para Kaizen testing
RUN mkdir -p /workspace/results

# Crear archivo de estado para health check
RUN touch /workspace/.ready

# Health check para Kubernetes readiness
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
    CMD test -f "$WORKSPACE_DIR/.ready" || exit 1

# Labels para identificación en Kaizen
LABEL maintainer="Kaizen Team - Bancolombia IDP" \
      purpose="Software Template Testing" \
      template-type="java-clean-architecture" \
      environment="sandbox"

ENTRYPOINT ["/workspace/java-template-test.sh"]
