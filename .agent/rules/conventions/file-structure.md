---
trigger: always_on
---

# File Structure Standard

feature-module
 ├── application
 │   ├── ports
 │   ├── use-cases
 │   └── dto
 ├── domain
 │   ├── entities
 │   ├── ports
 │   ├── interfaces
 │   ├── value-objects (optional)
 │   └── enums (optional)
 ├── infrastructure
 │   ├── adapters
 │   │   ├── inbound
 │   │   │   ├── http (optional)
 │   │   │   │   ├── <feature>.controller.ts
 │   │   │   │   └── dto
 │   │   │   │       └── <feature>.http.dto.ts
 │   │   │   ├── messaging (optional)
 │   │   │   │   └── <feature>.consumer.ts
 │   │   │   └── grpc (optional)
 │   │   │       └── <feature>.grpc.controller.ts
 │   │   └── outbound
 │   │       ├── repositories (optional)
 │   │       │   ├── mongo-<entity>.repository.impl.ts
 │   │       │   ├── redis-<entity>.repository.impl.ts
 │   │       │   └── sql-<entity>.repository.impl.ts
 │   │       ├── cache (optional)
 │   │       │   └── redis-<entity>.cache.impl.ts
 │   │       ├── clients (optional)
 │   │       │   ├── <external>.rest.client.ts
 │   │       │   ├── <external>.grpc.client.ts
 │   │       │   └── <external>.soap.client.ts
 │   │       ├── engines (optional)
 │   │       │   └── <engine>.engine.adapter.ts
 │   │       ├── messaging (optional)
 │   │       │   ├── <event>.kafka.publisher.ts
 │   │       │   └── <event>.servicebus.publisher.ts
 │   │       └── mappers (optional)
 │   │           ├── inbound.mapper.ts
 │   │           └── outbound.mapper.ts
 │   └── persistence
 │       ├── schemas (optional)
 │       │   └── <entity>.schema.ts
 │       └── migrations (optional)
 │           └── <entity>.migration.ts
 └── feature.module.ts

Rules:

- Subfolders are created only when required by detected capabilities.
- Inbound adapters belong only to `infrastructure/adapters/inbound/*`.
- Outbound adapters belong only to `infrastructure/adapters/outbound/*`.
- HTTP DTOs for controllers belong to `infrastructure/adapters/inbound/http/dto`.
- Use one HTTP DTO file per feature inbound HTTP adapter (`<feature>.http.dto.ts`) and reuse it across CRUD endpoints.
- HTTP DTO classes must use `class-validator` (and `class-transformer` when nested mapping is needed).
- Do not define DTO classes inline inside controller files; controller `@Body()` types must reference DTO classes from `infrastructure/adapters/inbound/http/dto/*`.
- Messaging consumers belong to `infrastructure/adapters/inbound/messaging`.
- gRPC inbound handlers belong to `infrastructure/adapters/inbound/grpc`.
- Application DTOs belong to `application/dto`.
- Application DTOs should be limited to two per feature by default: `*.request.dto.ts` and `*.response.dto.ts`.
- Inbound contracts belong to `application/ports`.
- HTTP controllers must depend on the inbound contract in `application/ports` (not directly on individual use cases).
- Controllers should contain transport concerns only (decorators, validation/interceptors, parameter extraction, direct delegation).
- Do not compose business payloads or merge request structures inside controllers; move mapping/orchestration to application service/use case or infrastructure mappers.
- Outbound ports belong to `domain/ports`.
- Ports are abstract classes only.
- Domain ports must depend only on domain contracts (models/entities/interfaces) and must not import `application/dto/*`.
- Outbound integration clients belong to `infrastructure/adapters/outbound/clients`.
- Outbound event publishers belong to `infrastructure/adapters/outbound/messaging`.
- Cross-layer translation helpers inside infrastructure belong to `infrastructure/adapters/outbound/mappers`.
- Outbound mappers are the default place to assemble external request payloads, URL path/query segments, headers, and persistence document shapes (for example `mongoData(...)`).
- Application mappers (`application/mappers/*`) are responsible for translating application DTOs to domain port contracts when needed.
- Import path policy for generated code:
  - Prefer absolute imports using aliases (`@app/*`, `@commons/*`, `@modules/*`, and module alias such as `@products/*`) over deep relative paths.
  - Module declaration/wiring files (`*.module.ts`) may keep short relative imports when that improves local module readability.
- Redis never inside `persistence`.
- Persistence contains DB schemas/migrations only.
