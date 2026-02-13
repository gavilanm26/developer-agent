---
description: Protocolo AGENTE para crear un servicio completo (Scaffold + Lógica + Tests + Docs)
trigger: user_request_new_service_with_description
---

# End-to-End Microservice Creation Protocol

Este workflow define cómo el Agente debe proceder cuando el usuario solicita un nuevo microservicio con una descripción funcional (ej: "Crear servicio de pagos con Stripe").

## Fase 1: Scaffolding (Automático)

1.  **Ejecutar Script de Generación**:
    -   Comando: `./dev-agent.sh new-service nestjs <service-name>`
    -   *Nota*: Esto creará la estructura base y copiará el cerebro (`.gemini`) al nuevo repo.

## Fase 2: Análisis & Diseño (Mental)

2.  **Leer Descripción del Usuario**:
    -   Identificar Casos de Uso (ej: `ProcessPayment`, `RefundTransaction`).
    -   Identificar Puertos Requeridos (ej: `PaymentGatewayPort`, `TransactionRepositoryPort`).
    -   Identificar Adaptadores (ej: `StripeAdapter`, `TypeOrmRepository`).

3.  **Planificar Estructura Hexagonal**:
    -   Diseñar la firma de los Puertos (Clases Abstractas).
    -   Diseñar los DTOs de entrada/salida.

## Fase 3: Implementación (Código)

4.  **Generar Módulo (si aplica)**:
    -   Si el servicio es complejo, usar `./dev-agent.sh new-module <module-name>`.

5.  **Codificar Capa de Dominio**:
    -   Crear Entidades y Value Objects en `src/<module>/domain/entities`.
    -   Crear Puertos en `src/<module>/domain/ports` (**Abstract Classes**).

6.  **Codificar Capa de Aplicación**:
    -   Implementar Casos de Uso en `src/<module>/application/use-cases`.
    -   Inyectar *solo* los puertos del dominio.

7.  **Codificar Capa de Infraestructura**:
    -   Implementar Adaptadores en `src/<module>/infrastructure/adapters`.
    -   Crear Controladores en `src/<module>/infrastructure/inbound/start`.

## Fase 4: Verificación & Pruebas

8.  **Generar Tests Unitarios**:
    -   Crear tests para cada Caso de Uso (`.spec.ts`).
    -   Mockear los puertos para probar la lógica pura.

9.  **Validar Compilación**:
    -   Ejecutar `npm run build` para asegurar que no hay errores de tipos.

## Fase 5: Entrega

10. **Generar Documentación de Prueba**:
    -   Crear un archivo `curl-tests.sh` o `postman_collection.json` en la raíz.
    -   Incluir ejemplos de requests válidos e inválidos.

11. **Notificar al Usuario**:
    -   Confirmar que el servicio está listo, probado y 'self-aware'.
