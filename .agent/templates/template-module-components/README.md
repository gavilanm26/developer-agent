# Template Module Components

Reusable templates for strict hexagonal NestJS modules.

These templates are references for implementation style (Redis, Mongo, outbound REST clients, logging helpers, and wiring),
while the final generated structure must follow the current `.agent` rules.
Auth-specific full module templates are located in `.agent/templates/template-module-auth/`.
API Gateway-specific templates are located in `.agent/templates/templates-gateway/` and `.agent/templates/templates-gateway-endpoint/`.

## Structural defaults enforced by rules

- Ports in `application/ports` and `domain/ports` are abstract classes only.
- Implementations that satisfy those ports should use `implements` (not `extends`).
- HTTP controller depends on the inbound application port (not directly on use cases).
- HTTP inbound uses a single DTO file (`<feature>.http.dto.ts`) with `class-validator`.
- Application DTOs default to only two files per feature:
  - `<feature>.request.dto.ts`
  - `<feature>.response.dto.ts`

## Common placeholders

- `{{FEATURE_KEBAB}}` / `{{FEATURE_PASCAL}}`
- `{{ENTITY_KEBAB}}` / `{{ENTITY_PASCAL}}`
- `{{EXTERNAL_KEBAB}}` / `{{EXTERNAL_PASCAL}}`
- `{{PORT_PASCAL}}` (abstract class port)
- `{{REQUEST_DTO_PASCAL}}` / `{{RESPONSE_DTO_PASCAL}}`
- `{{HTTP_DTO_PASCAL}}`
- `{{REQUEST_DTO_IMPORT}}` / `{{RESPONSE_DTO_IMPORT}}`
- `{{METHOD_NAME}}`
- `{{BASE_URL_ENV}}`
- `{{API_VERSION}}`
- `{{ROUTE_PATH}}`
- `{{DB_NAME}}`
- `{{REDIS_TOKEN}}` (default: `REDIS`)
- `{{REDIS_PREFIX}}`
- `{{MONGO_SCHEMA_PASCAL}}`
- `{{MONGO_MODEL_CONST}}`
- `{{MONGO_COLLECTION}}`
- `{{MONGO_LOG_OPERATION}}`
- `{{MONGO_FIND_FILTER_TYPE}}`
- `{{MONGO_DOMAIN_ENTITY_PASCAL}}`
- `{{MONGO_DOMAIN_ENTITY_IMPORT}}`

## Bootstrap

- Standard backend microservice bootstrap template:
  - `wiring/main.ts.tpl`
- Expected bootstrap wiring includes:
  - `OpenTelemetryConfig.initialize()`
  - `GrafanaLoggerConfig`
  - global `AllExceptionsFilter`
  - global `ValidationPipe`
  - `helmet`
  - `json/urlencoded` body limits
  - `ConfigService`-driven port resolution

## Notes

- `outbound/clients/*` templates use `httpLogger` and satisfy abstract-class ports via `implements`.
- `outbound/mappers/set-data.mapper.ts` is an injectable mapper (`@Injectable`) with instance methods for assembling URL params, headers, outbound request bodies, and optional Mongo document shapes (`mongoData`).
- When mapper headers are required, they should be built from `CommonHeaders` and extended with operation-specific headers.
- Prefer domain entity/interface types for mapper/client `data` parameters; avoid inline object literal types so contracts can evolve without signature churn.
- For Mongo adapters, keep repository focused on persistence and logging; use mapper primarily for persistence-to-domain mapping (`mapMongoToEntity`) and add extra mapper methods only when there is real transformation value.
- Default pattern is a single `SetDataMapper` per module (HTTP + Mongo shaping/mapping). Avoid creating extra `Mongo*DataMapper` classes unless explicitly requested.
- For document-owned operations, default outbound headers include `X-Invoker-User` and `X-Invoker-RequestNumber` from `documentType + documentNumber`.
- Do not include tracking headers in outbound mapper headers by default unless target API contract explicitly requires them.
- Do not include credential/token headers (`client_id`, `client_secret`, `authorization`) in templates by default; add them only for explicitly requested real external API auth integrations.
- Mongo repository template uses `internalLogger`.
- Mongo repository adapters should stay persistence-focused (query/filter/mapping/logging) and avoid domain business decisions by default.
- Redis cache/provider templates use standard env keys (`INFRAREDISHOST`, `INFRAREDISPORT`, `INFRAREDISPASS`).
- Redis TTL standard env key is `INFRAREDISTTL`.
- Redis cache port/adapter default contract is `get`/`set` only; extra methods (for example `del`, `invalidate`, list-specific helpers) must be explicitly requested.
- Do not add mock/in-memory branches inside production adapters or modules; mocks belong only in specs.
- Add unit tests for outbound mappers by default (`set-data.mapper.spec.ts`) because request/header/url/document assembly is critical behavior.
- Use `.agent/tools/scripts/render-template-commons.sh` before generating adapters that depend on `src/commons/http-logger/*`.
