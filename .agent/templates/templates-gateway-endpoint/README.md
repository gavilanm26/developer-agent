# API Gateway Endpoint Template

Plantilla oficial para la creación de **nuevos Endpoints dentro de un API Gateway** (como `bcs-commons-api-gateway-identity-management` o `bcs-cdt-api-gateway`).

Aunque el API Gateway funcione primordialmente como un enrutador o puente hacia otros microservicios (Backend For Frontend), es imperativo que internamente cumpla al pie de la letra con **Clean Architecture**.

## Estructura Esperada (Hexagonal Architecture / DDD)

Todos los endpoints generados (ej. `verify-user`, `get-config`) bajo `src/endpoint/{{SERVICE_KEBAB}}` deben seguir estrictamente esta jerarquía:

```text
src/endpoint/{{SERVICE_KEBAB}}/
├── application/
│   ├── use-cases/
│   │   ├── {{SERVICE_KEBAB}}.usecase.ts          # Reglas del Gateway (validaciones de token, agregación simple)
│   │   └── {{SERVICE_KEBAB}}.usecase.spec.ts
│   └── ports/
│       └── {{SERVICE_KEBAB}}.usecase.port.ts     # Interface que el UseCase implementa
├── domain/
│   └── ports/
│       └── {{SERVICE_KEBAB}}.client.port.ts      # Cliente HTTP hacia microservicios downstream
├── infrastructure/
│   └── adapters/
│       ├── inbound/
│       │   └── http/
│       │       ├── {{SERVICE_KEBAB}}.controller.ts
│       │       └── {{SERVICE_KEBAB}}.controller.spec.ts
│       └── outbound/
│           └── clients/
│               └── core/
│                   ├── {{SERVICE_KEBAB}}.rest.client.ts      # Implementa {{SERVICE_KEBAB}}.client.port.ts
│                   └── {{SERVICE_KEBAB}}.rest.client.spec.ts
└── {{SERVICE_KEBAB}}.module.ts
```

## Convenciones Estrictas para API Gateway

1. **DTOs Centralizados (Sin Models Locales):** Como es un API Gateway, NO hay una carpeta `domain/models/` por módulo. Todos los Request y Response DTOs son genéricos y se reutilizan desde la carpeta raíz `src/dto/`.
2. **Uso de UseCases:** La capa de aplicación DEBE usar `use-cases` y no `services`. La carpeta es `application/use-cases/`.
3. **Nomenclatura de Archivos RestClient:** Las inyecciones para el downstream (_hacia otros microservicios_) no deben llamarse `MsFooClient` de manera ad-hoc. Deben llamarse directamente `{{SERVICE_PASCAL}}RestClient` implementando `{{SERVICE_PASCAL}}ClientPort` bajo la carpeta `/infrastructure/adapters/outbound/clients/microservices/`.
4. **Sin Mapeo Outbound:** Debido a que el Gateway delega los payloads estructurados directamente al core downstream, NO se necesita una carpeta `mappers`. Se envía el DTO validado limpio hacia el cliente.
5. **No Acoplamiento:** Absolutamente ningún archivo en `domain/` puede tener dependencias (imports) que provengan de `application/` ni de `infrastructure/`.
