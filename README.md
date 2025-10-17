# 🎌 Kaizen Java Scaffolder Docker Image

Docker image para ejecutar scaffolding de **Java Clean Architecture** de Bancolombia utilizando el plugin oficial `co.com.bancolombia.cleanArchitecture`.

## 🏷️ Imagen

```
docker pull <your-username>/kaizen-java-scaffolder:latest
```

## 🏗️ Contenido

Esta imagen contiene:
- ✅ **Gradle 8.10** con JDK 21
- ✅ **Plugin Clean Architecture 3.23.0** de Bancolombia
- ✅ Script de scaffolding completo y funcional
- ✅ Assets de Bancolombia (Dockerfile, k8s manifests, logback.xml)
- ✅ Herramientas: `jq`, `git`, `curl`

## 🚀 Uso Local

### Scaffolding Básico

```bash
docker run --rm \
  -e PROJECT_NAME=my-app \
  -e PACKAGE=com.bancolombia.myapp \
  -e TYPE=reactive \
  -v $(pwd)/output:/workspace \
  <your-username>/kaizen-java-scaffolder:latest
```

### Scaffolding Completo

```bash
docker run --rm \
  -e PROJECT_NAME=complete-app \
  -e PACKAGE=com.bancolombia.demo \
  -e TYPE=reactive \
  -e JAVA_VERSION=VERSION_21 \
  -e MODELS=user,order \
  -e USE_CASES=create-user,process-order \
  -e ENTRY_POINTS='[{"EntryPoint":"webflux","server":"undertow","router":"true"}]' \
  -e DRIVEN_ADAPTERS='[{"DrivenAdapter":"r2dbc-postgresql","secret":"true"}]' \
  -v $(pwd)/output:/workspace \
  <your-username>/kaizen-java-scaffolder:latest
```

## 🔧 Variables de Entorno

### Obligatorias

| Variable | Descripción | Default | Ejemplo |
|----------|-------------|---------|---------|
| `PROJECT_NAME` | Nombre del proyecto | `demo-app` | `my-reactive-api` |

### Configuración del Proyecto

| Variable | Descripción | Default | Valores |
|----------|-------------|---------|---------|
| `PACKAGE` | Package base Java | `com.bancolombia` | `com.bancolombia.myapp` |
| `TYPE` | Tipo de arquitectura | `reactive` | `reactive`, `imperative` |
| `JAVA_VERSION` | Versión de Java | `VERSION_21` | `VERSION_17`, `VERSION_21` |
| `LOMBOK` | Habilitar Lombok | `true` | `true`, `false` |
| `METRICS` | Habilitar métricas | `true` | `true`, `false` |
| `MUTATION` | Habilitar mutation testing | `true` | `true`, `false` |

### Componentes Opcionales

| Variable | Descripción | Formato | Ejemplo |
|----------|-------------|---------|---------|
| `MODELS` | Modelos del dominio | CSV | `user,order,product` |
| `USE_CASES` | Casos de uso | CSV | `create-user,update-user` |
| `ENTRY_POINTS` | Entry points | JSON Array | Ver ejemplos abajo |
| `DRIVEN_ADAPTERS` | Driven adapters | JSON Array | Ver ejemplos abajo |

### Ejemplos de Entry Points

```bash
# REST API con WebFlux
ENTRY_POINTS='[{"EntryPoint":"webflux","server":"undertow","router":"true"}]'

# Event Handler asíncrono
ENTRY_POINTS='[{"EntryPoint":"async-event-handler","server":"undertow"}]'

# Múltiples entry points
ENTRY_POINTS='[{"EntryPoint":"webflux","server":"undertow"},{"EntryPoint":"async-event-handler"}]'
```

### Ejemplos de Driven Adapters

```bash
# PostgreSQL con R2DBC
DRIVEN_ADAPTERS='[{"DrivenAdapter":"r2dbc-postgresql","secret":"true"}]'

# MongoDB Reactive
DRIVEN_ADAPTERS='[{"DrivenAdapter":"mongodb-reactive","secret":"true"}]'

# REST Consumer
DRIVEN_ADAPTERS='[{"DrivenAdapter":"rest-consumer","url":"https://api.example.com"}]'

# Múltiples adapters
DRIVEN_ADAPTERS='[{"DrivenAdapter":"r2dbc-postgresql","secret":"true"},{"DrivenAdapter":"redis"}]'
```

## 🏗️ Build Local

```bash
# Build
docker build -t kaizen-java-scaffolder:local .

# Test
docker run --rm \
  -e PROJECT_NAME=test-app \
  -v $(pwd)/test-output:/workspace \
  kaizen-java-scaffolder:local
```

## 🔄 CI/CD

Este repositorio usa GitHub Actions para:
1. Build automático en push a `main`
2. Push a Docker Hub con tags:
   - `latest`
   - `YYMMDD-HHMM` (timestamped)

### Configurar Secrets

En GitHub: Settings → Secrets → Actions

**Variables**:
- `DOCKERHUB_USERNAME`: Tu usuario de Docker Hub

**Secrets**:
- `DOCKERHUB_TOKEN`: Access token de Docker Hub

## 📁 Estructura

```
docker-images/
├── .github/
│   └── workflows/
│       └── ci.yaml          # GitHub Actions workflow
├── assets/                   # Assets de Bancolombia
│   ├── azure_build.yaml     # Template de Azure Pipeline
│   ├── Dockerfile           # Dockerfile para el app
│   ├── logback.xml          # Configuración de logs
│   └── k8s/                 # Manifiestos K8s
│       ├── app.yaml
│       ├── configmap.yaml
│       ├── gateway.yaml
│       └── hpa.yaml
├── src/
│   └── java-template-tester/
│       └── java-template-test.sh  # Script principal
├── Dockerfile                # Multi-stage Dockerfile
└── README.md
```

## 🔍 Debugging

### Ver logs durante build

```bash
docker build --progress=plain -t kaizen-java-scaffolder:debug .
```

### Ejecutar interactivamente

```bash
docker run -it --rm \
  -e PROJECT_NAME=debug-app \
  --entrypoint /bin/bash \
  <your-username>/kaizen-java-scaffolder:latest
```

Dentro del container:
```bash
# Verificar Gradle
gradle --version

# Verificar Java
java -version

# Ejecutar manualmente
cd /workspace
PROJECT_NAME=test-app PACKAGE=com.test ./java-template-test.sh
```

## 🐛 Troubleshooting

### Error: `GRADLE_HOME not configured`

La imagen base `gradle:8.10-jdk21` ya configura `GRADLE_HOME`. Verificar que estés usando la imagen correcta.

### Error: `Plugin not found`

El plugin se descarga de Artifactory Bancolombia. Verificar conectividad:
```bash
curl -I https://artifactory.apps.bancolombia.com:443/maven-bancolombia/
```

### Error: Permisos denegados

Verificar que el usuario `appuser` (UID 1000) tenga permisos:
```bash
docker run -it --rm --entrypoint /bin/bash <image> -c "whoami && id"
```

## 📊 Outputs

Al finalizar exitosamente, se genera:

### `/app/results/scaffold_status`
```
success
```

### `/app/results/report.json`
```json
{
  "status": "success",
  "project_name": "my-app",
  "package": "com.bancolombia.myapp",
  "type": "reactive",
  "java_version": "VERSION_21",
  "files_generated": 156,
  "directories_created": 42,
  "timestamp": "2025-10-17T10:30:45-05:00"
}
```

### Estructura del proyecto generado
```
/workspace/my-app/
├── applications/
│   └── app-service/
├── deployment/
│   ├── Dockerfile
│   ├── azure_build.yaml
│   └── k8s/
├── domain/
│   ├── model/
│   └── usecase/
├── infrastructure/
│   ├── driven-adapters/
│   └── entry-points/
├── build.gradle
├── settings.gradle
├── main.gradle
└── gradlew
```

## 🔐 Security

- ✅ Usuario no-root (UID 1000, GID 2000)
- ✅ Capabilities dropped
- ✅ Read-only root filesystem (donde sea posible)
- ✅ Health checks configurados
- ✅ Resource limits recomendados

## 📚 Referencias

- [Plugin Clean Architecture](https://github.com/bancolombia/scaffold-clean-architecture)
- [Gradle Docker Images](https://hub.docker.com/_/gradle)
- [Clean Architecture Book](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 🤝 Contributing

Este es un repositorio privado para uso interno de Bancolombia. Para contribuir:

1. Crear un branch desde `main`
2. Hacer tus cambios
3. Crear un PR con descripción detallada
4. Esperar review del equipo Kaizen

## 📝 License

Propiedad de Bancolombia S.A. - Uso interno únicamente.

## 📞 Soporte

- 💬 Slack: `#kaizen-support`
- 📧 Email: kaizen-team@bancolombia.com.co
- 🎫 Issues: GitHub Issues en este repositorio
