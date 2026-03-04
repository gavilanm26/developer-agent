---
trigger: always_on
---

# Capability Detection

Before scaffolding, detect required capabilities:

- HTTP endpoint
- Database persistence
- Redis cache
- External API client
- Messaging
- Rule engine
- Shared commons bootstrap (logging / otel / interceptors)
- Microservice type: API Gateway vs standard backend microservice
- Domain ownership type: customer-owned resource vs global/catalog resource

Generate:

- Shared commons templates first (only required ones)
- Capability dependencies (npm packages) first, before generating code that imports them
- Domain entities and outbound ports first
- Application DTOs and inbound contracts second
- Application use cases / orchestrators third
- Infrastructure outbound adapters fourth
- Infrastructure inbound adapters (http/messaging/grpc) fifth
- Persistence artifacts (schemas/migrations) sixth (if required)
- Bindings in `feature.module.ts` last

Template source:

- Use `.agent/templates/` only
- For shared microservice commons, use `.agent/templates/template-commons/*`
- For new API Gateway microservices, use `.agent/templates/templates-gateway/*` as base
- For modules inside API Gateway microservices, use `.agent/templates/templates-gateway-endpoint/*`
- Render `*.tpl` files by replacing placeholders and removing the `.tpl` suffix in generated project files
- Standard backend microservice guardrail:
  - Do not use `templates-gateway/*` as source for commons/dto/bootstrap in non-gateway microservices.
  - Use `template-commons` + backend module templates as source of truth.

Never generate unused technologies.

Ownership-aware generation (mandatory when detected):

- If the feature models customer-owned resources (for example products/account/payment tied to a customer), scaffold owner fields by default in:
  - domain entity
  - application request/response DTOs
  - inbound HTTP DTO
  - persistence schema/document
- Prefer `customerId` as owner key; if not available, scaffold `documentType` + `documentNumber`.
- If `documentType` is present in HTTP DTOs, scaffold/import `commons/enums/type-of-documents.enum` and type `documentType` as `TypeOfDocuments` (instead of plain `string`).
- For customer-owned resources, generate owner-filter retrieval paths when explicitly required by the requested API contract; do not force owner filters when the user asks for global list + id-based retrieval.

Capability -> expected artifacts (minimum checklist)

- HTTP endpoint
  - `infrastructure/adapters/inbound/http/<feature>.controller.ts`
  - `infrastructure/adapters/inbound/http/dto/<feature>.http.dto.ts`
  - HTTP controller spec (`*.controller.spec.ts`)
  - For non-gateway modules, do not add root `src/dto/*` by default.

- Application orchestration (default for HTTP features)
  - `application/ports/<feature>.usecase.ts` (abstract class)
  - `application/<feature>.impl.service.ts`
  - `application/dto/<feature>.request.dto.ts`
  - `application/dto/<feature>.response.dto.ts`
  - `*.impl.service.spec.ts`
  - `*.usecase.spec.ts` for each use case

- Auth module specialization
  - Use `.agent/templates/template-module-auth/with-re-captcha/*` when reCAPTCHA is required
  - Use `.agent/templates/template-module-auth/without-re-captcha/*` when reCAPTCHA is not required
  - `without-re-captcha` must not import or depend on `re-captcha` module/ports
  - Auth DTO/interface/request contracts must type `documentType` as `TypeOfDocuments` (`@commons/enums/type-of-documents.enum`)
  - Auth outbound mapper may use `commons/libs/crypto/crypto-core` for encryption
  - Auth env must include `INFRAENCRYPTKEYCORE` when crypto-based password encryption is used

- OTC module specialization
  - If the requested module is `otc`, select `.agent/templates/template-module-otc/otc/*` as template source.
  - Treat OTC as a composite module with mandatory submodules `generate` and `validate`.
  - Generate/update both submodules together unless the user explicitly requests only one of them.

- External API client (REST)
  - `domain/ports/<external>.client.port.ts` (abstract class)
  - `infrastructure/adapters/outbound/clients/<external>.rest.client.ts`
  - `infrastructure/adapters/outbound/mappers/set-data.mapper.ts` (or domain-specific mapper)
  - Outbound client should inject mapper instance (`private readonly set: SetDataMapper`) and delegate URL/request/header assembly to mapper methods.
  - Mapper `headers(...)` should use `CommonHeaders` from `commons/headers/common-headers` when request context is available.
  - Outbound mapper/client data arguments should be typed with domain entities/interfaces, not inline object literal types.
  - For document-owned operations, mapper headers should include `X-Invoker-User` and `X-Invoker-RequestNumber` from `documentType + documentNumber`.
  - Do not include tracking headers (`X-Tracking-Op` / `x-tracking-op`) by default in outbound headers unless explicitly required by the target API contract.
  - Credential headers (`client_id`, `client_secret`, `authorization`) are opt-in and must be generated only when user confirms real external API auth requirements.
  - `*.rest.client.spec.ts`
  - `*.mapper.spec.ts`

- Redis cache
  - `domain/ports/<entity>.cache.port.ts` (abstract class)
  - `infrastructure/adapters/outbound/cache/redis-<entity>.cache.impl.ts`
  - Redis provider binding in `<feature>.module.ts` using `'REDIS'` and `useValue: new Redis(...)` with `process.env.INFRAREDISHOST|INFRAREDISPORT|INFRAREDISPASS`
  - Default cache contract is only `get(key)` and `set(key, value)`; do not scaffold `invalidate`/`del`/list-specialized methods unless explicitly requested by the user.
  - Cache adapter TTL should be read via `ConfigService` from the selected TTL env key and default to `1800` when missing.
  - `*.cache.impl.spec.ts`

- Mongo/Mongoose persistence
  - `src/app.module.ts` includes `MongooseModule.forRootAsync(...)` with `APPMONGOSTRING` and service `dbName`
  - `<feature>.module.ts` includes `MongooseModule.forFeature([...])`
  - `infrastructure/persistence/schemas/<entity>.schema.ts`
  - `domain/ports/<entity>.repository.port.ts` (abstract class)
  - `infrastructure/adapters/outbound/repositories/mongo-<entity>.repository.impl.ts`
  - Mongo repositories should avoid domain/business branching (for example rule activation decisions, domain exceptions) unless user explicitly requests that behavior inside persistence layer.
  - if request/header/document shaping exists: outbound mapper with `mongoData(...)`; include mapper methods for query/filter shaping as needed (for example `mongoFilterData(...)`, `mapMongoToEntity(...)`)
  - Prefer a single module mapper (`SetDataMapper`) for outbound HTTP + Mongo shaping/mapping unless user explicitly requests separated mapper classes.
  - `*.repository.impl.spec.ts`
  - `*.mapper.spec.ts` when mapper contains Mongo document assembly logic

Capability dependency notes (minimum examples):

- External API client (REST with Nest `HttpService`) usually requires `@nestjs/axios`
- OTel bootstrap requires OpenTelemetry packages used by `src/commons/otel.config.ts`
- Redis cache requires the selected Redis client package and adapter bindings
- Database persistence requires the selected ORM/driver packages
- For local validation loops, keep the real adapter/module wiring. If infra is unavailable, validation may be blocked and must be reported (do not generate fake in-memory replacements in production code).

Agents must install only the dependencies needed by detected capabilities.
Agents must generate `.env` entries only for detected capabilities.
Agents must avoid adding capability-specific dependencies when the related capability is not present.

Capability -> npm packages reference (minimum baseline):

- HTTP endpoint (Nest REST):
  - Usually covered by Nest base scaffold (`@nestjs/common`, `@nestjs/core`, `@nestjs/platform-express`)
  - `class-validator`
  - `class-transformer`
- External API client (REST):
  - `@nestjs/axios`
  - `axios`
- Auth module encryption:
  - `crypto-js`
- OTel bootstrap:
  - `@opentelemetry/sdk-node`
  - `@opentelemetry/auto-instrumentations-node`
  - `@opentelemetry/exporter-trace-otlp-proto`
  - `@opentelemetry/resources`
- Redis cache:
  - Choose one client strategy and install only one baseline set (example: `ioredis` or `redis`)
  - Install `@types/ioredis` only when `ioredis` is selected and project typing requires it
- Messaging (Kafka):
  - `kafkajs` (if using Nest Kafka transport/client)
- Messaging (Service Bus):
  - corresponding Azure Service Bus SDK package selected by the project standard
- gRPC:
  - `@grpc/grpc-js`
  - `@grpc/proto-loader` (if proto-loader approach is used)
- Database (Mongo/Mongoose):
  - `mongoose`
  - `@nestjs/mongoose` (if Nest integration is used)
- Database (SQL/TypeORM):
  - `typeorm`
  - selected SQL driver (`pg`, `mysql2`, etc.)
  - `@nestjs/typeorm` (if Nest integration is used)
- Database (SQL/Prisma):
  - `prisma` (dev)
  - `@prisma/client`
- Commons `https-agent/*` or `token/*`:
  - `@nestjs/axios`
  - `axios`
- Commons `basic-data/*`:
  - `@nestjs/axios`
  - `axios`
- Commons `libs/generate-uuid/*`:
  - Prefer Node built-in `crypto.randomUUID()` (no extra package)
  - Only install `uuid` if the selected template/version explicitly requires it

Shared commons selection notes (avoid over-copying):

- `template-commons` is the superset baseline (based on the richest internal commons implementation)
- Copy only the subfolders/files required by the detected capabilities of the target microservice
- Logging only: scaffold `commons/http-logger/*`
- OTel only: scaffold `commons/otel.config.ts.tpl`
- Global exception handling only: scaffold `commons/filters/*` and `commons/exceptions/*`
- Header interceptor only: scaffold `commons/interceptor/*`
- Health endpoint only: scaffold `commons/health-check/*`
- Standard headers helper set: `commons/constants/*`, `commons/headers/*`, `commons/libs/*` (and optional `commons/enums/*`)
- Auth-only crypto helper: `commons/libs/crypto/*` (scaffold only for auth modules)
  - When using `.agent/tools/scripts/render-template-commons.sh`, include `crypto` component only for auth scenarios
- HTTPS outbound client support: `commons/https-agent/*`
- Shared token client support: `commons/token/*`
- Shared basic-data client support: `commons/basic-data/*`
- `commons/token/*` is a shared commons component: copy it as-is from `template-commons` and do not generate additional hexagonal layers/modules around it.
- When `commons/token` is selected, wire `TokenModule` from `commons/token/token.module` into `app.module.ts` imports and into any feature module that depends on `TokenAdapter`.
- `commons/basic-data/*` is a shared commons component: copy it as-is from `template-commons` and do not generate additional hexagonal layers/modules around it.
- When `commons/basic-data` is selected, wire `BasicDataModule` from `commons/basic-data/basic-data.module` into `app.module.ts` imports and into any feature module that depends on `GetBasicDataImplAdapter`.
- If copying the full `template-commons` superset, install all transitive dependencies introduced by selected commons packs before compilation
- If a copied commons file imports third-party packages, ensure those packages are added to capability dependencies before compilation
- Env generation must be capability-scoped:
  - Use `.agent/templates/global/.env.tpl` as source of truth.
  - Render `.env`/`.env.example` with `.agent/tools/scripts/render-env-from-template.sh`.
  - Keep only variables required by selected capabilities and preserve template values as-is.
- Mongoose wiring note:
  - `MongooseModule.forRootAsync(...)` belongs in `app.module.ts` using `APPMONGOSTRING` and a fixed `dbName` for the service context
  - Do not hardcode fallback URIs (for example `mongodb://localhost:27017`) in production module wiring.
  - If `APPMONGOSTRING` is missing, use an explicit marker value (for example `APPMONGOSTRING NOT FOUND`) instead of localhost fallbacks.
  - `MongooseModule.forFeature(...)` belongs in the feature module when Mongo is part of the requested capability set

Logging strategy generation notes:

- REST outbound client adapters should be generated with `httpLogger` integration (not raw request-operation `logger.log/error`)
- Repository/cache/engine adapters should use `internalLogger` when operation logs are required
- Mongo connection in `app.module.ts` should use the standard env key `APPMONGOSTRING` and a dynamic `dbName` matching the module/service context (or project-specific override)
- Infrastructure connection settings (Mongo/Redis/external base URLs) must not silently fallback to hardcoded local hosts in production wiring; prefer explicit env values and clear marker values when required env vars are missing.
- Redis provider wiring should default to standard env keys: `INFRAREDISHOST`, `INFRAREDISPORT`, `INFRAREDISPASS`
- For Redis provider wiring, do not hardcode host/port/password defaults in module/provider code; use `process.env` values directly in the provider binding pattern.
- Redis cache TTL env key must be `INFRAREDISTTL` unless the user explicitly requests a different key.
- External API mocking policy:
  - If mocking is required for validation, use Postman MCP mock server flow.
  - Do not scaffold local filesystem mock servers as default project artifacts.
