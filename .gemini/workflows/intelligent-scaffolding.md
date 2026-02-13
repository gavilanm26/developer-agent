---
description: Generación adaptativa de estructura hexagonal basada en capacidades
---

# Intelligent Scaffolding

Este flujo de trabajo automatiza la creación de la estructura hexagonal mínima necesaria para una funcionalidad.

## Pasos

1. **Detección de Capacidades:**
   Analizar la funcionalidad requerida e identificar qué componentes son necesarios:
   - Endpoint HTTP -> `inbound/http`
   - Persistencia -> `repository port` + `adapter` + `schema`
   - API Externa -> `client port` + `adapter`
   - Reglas (Zen) -> `engine port` + `adapter`
   - Eventos -> `messaging port` + `publisher/consumer`

2. **Creación de Estructura Base:**
   Generar siempre:
   - `application/`
   - `domain/`
   - `infrastructure/`
   - `feature.module.ts`

3. **Generación de Puertos (Domain First):**
   - Siempre crear el puerto en el dominio antes que el adaptador en infraestructura.

4. **Generación de Adaptadores:**
   - Solo si existe el puerto correspondiente.

5. **Automatización de Inyección de Dependencias:**
   - Registrar automáticamente los bindings en el `feature.module.ts`.

## Reglas Críticas
- **Minimalismo**: NUNCA generar carpetas o archivos que no se vayan a usar.
- **Independencia**: El dominio debe permanecer agnóstico de frameworks.
