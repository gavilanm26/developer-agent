---
trigger: always_on
---

# Module Generation Rules

When creating a NEW MODULE:

Always use:

    nest g mo modules/<module-name>

Do NOT use automatic controller/service generation.
Do not create module root folders/files manually before generating the module with Nest CLI.
If the requested module does not exist yet, CLI generation is mandatory first:
nest g mo modules/<module-name>

Standard Microservice module specialization:

- If the target microservice is NOT an API Gateway, STRICTLY scaffold modules following `.agent/templates/template-module-microservice/README.md` conventions.
- You must use UseCases in `application/use-cases/`, Models in `domain/models/` (NOT interfaces), and name ports ending in `.port.ts` and `.client.port.ts` just as the template indicates.

API Gateway module specialization:

- If the target microservice is API Gateway, scaffold modules from `.agent/templates/templates-gateway-endpoint/base-endpoint/`.
- This template already contains working boilerplate code. Inject the endpoint name explicitly replacing `{{SERVICE_KEBAB}}` and `{{SERVICE_PASCAL}}` without overwriting the boilerplates inside the `.tpl` files.
- Use `base-endpoint` for generic gateway endpoints unless a specialized endpoint template exists (for example `auth`, `config-site`).
- Register generated endpoint modules in gateway `app.module.ts` imports (placeholder flow used by `templates-gateway`).
- Do not apply non-gateway module templates (`template-module-components`) as primary source for API Gateway modules.
- Gateway endpoint refactors/templates must preserve external behavior:
  - same inbound routes
  - same request/response contract shape
  - same required headers/status-code semantics unless explicitly requested otherwise

Controllers and services must follow hexagonal structure manually.
Controller must inject only the inbound application port (`application/ports/*.usecase.ts`) and not individual use cases directly.
For HTTP CRUD modules, default to:

- one HTTP DTO file in `infrastructure/adapters/inbound/http/dto/<feature>.http.dto.ts`
- never declare request DTO classes inline in controller files; all `@Body()` contracts must come from DTO files under `infrastructure/adapters/inbound/http/dto/`
- one application request DTO and one application response DTO in `application/dto/`
- for standard backend microservices (non API Gateway), do not create/use root `src/dto/*` as default module scaffolding
- one application inbound port in `application/ports/`
- one application orchestrator service implementing that port and delegating to specific use cases
- if domain is customer-owned, include owner identity fields in request/response and support owner-scoped queries from initial scaffolding
- if owner identity uses `documentType`, HTTP DTO typing must use `TypeOfDocuments` from `commons/enums/type-of-documents.enum` (not plain `string`)
- for simple owner-scoped query filters, do not over-scaffold additional query DTO classes by default; use direct query params and validate pair consistency in application flow
- Concrete outbound/inbound adapter classes and application services should satisfy abstract-class ports via `implements` (do not `extends` port contracts)
- Prefer absolute alias imports in generated files (`@app/*`, `@commons/*`, `@modules/*`, and module alias such as `@products/*`).
- `*.module.ts` files may keep local relative imports for module wiring clarity.
- if the module has outbound integrations (external APIs and/or persistence document shaping), generate `infrastructure/adapters/outbound/mappers/*` and route URL/header/request/document assembly through those mappers (do not assemble in controller or repository/client inline)
- when an outbound domain port requires a contract different from inbound DTOs, generate/use an application mapper to transform `application/dto/*` -> `domain/models/*` before invoking the port
- Mongo repository adapters must contain only persistence concerns (query/filter execution, mapping, adapter-level logging). Do not implement domain/business decisions there.
- Mongo mapping to domain entity should be delegated to outbound mapper methods (`mapMongoToEntity`); add extra mapper methods (`mongoData`, `mongoFilterData`) only when there is concrete transformation value.
- By default, reuse the module `SetDataMapper` for Mongo shaping/mapping methods (including `mapMongoToEntity`) instead of creating an additional `Mongo*DataMapper` class. Create extra mapper classes only if explicitly requested.
- `SetDataMapper` must be an injectable class (`@Injectable`) with instance methods, not static-only utility methods.
- For outbound HTTP integrations, `SetDataMapper` should provide `url(...)`, `request(...)`, and `headers(...)` methods as needed by the use case. Include `mongoData(...)` only when persistence document shaping is required.
- `SetDataMapper.request(...)` must assemble the outbound API contract shape (field renames/nesting/defaults) and must not be a trivial passthrough wrapper with no transformation value.
- Keep outbound client and mapper contracts aligned: if client uses `this.set.url(input)`, mapper must expose `url(input)`; avoid generating dead calls such as `urlParameters(...)` unless that method exists in the mapper contract.
- Outbound integration mode policy (mandatory):
  - Real API and Mock API must use the same outbound client code path (`*RestClient` + `HttpService` + `httpLogger` + `SetDataMapper`).
  - The only switch between real and mock integrations is environment configuration (`APICOREURL`/base URL), not code branches.
  - Do not create `*MockClient` adapters with simulated business responses in production module code.
  - Do not add conditional logic in outbound clients based on mock mode (`if mock`, mock codes, inline fake responses).
  - If external API is unavailable, mock externally with Postman Mock Server and point base URL env to that mock.
- Do not type mapper/client data parameters with inline object literals (for example `{ documentType: string; documentNumber: string }`). Use a domain entity or domain interface type (for example `ProductEntity`) to preserve extensibility for future headers/contracts.
- Do not use application DTO types as method signatures in `domain/ports/*`; use domain contracts only.
- When `headers(...)` is required, build headers from `CommonHeaders` (`commons/headers/common-headers`) and then extend with operation-specific headers (processId, auth, etc.).
- Do not add `X-Tracking-Op` / `x-tracking-op` in outbound mapper headers by default unless the target external integration explicitly requires those headers.
- For document-owned operations, outbound mapper headers should include `X-Invoker-User` and `X-Invoker-RequestNumber` from `documentType + documentNumber`.
- Do not scaffold `client_id`, `client_secret`, or `authorization` headers by default in `SetDataMapper.headers(...)`.
- Add credential/token headers only when the user explicitly confirms a real external API integration and provides required auth details/env keys.
- Register `SetDataMapper` in the feature module providers whenever an outbound client injects it.
- Do not generate in-memory infra implementations (`InMemoryRedis*`, in-memory repositories, fake external clients) inside feature modules/adapters as scaffolding defaults.
- Do not generate controller-side payload composition/merge logic; if translation is needed, generate a mapper or move translation to the application service.
- For Redis cache contracts, generate only `get`/`set` methods by default. Generate additional cache operations only when the user explicitly requests them.
- If outbound adapters are generated, scaffold their spec files in the same pass (client/repository/cache/mapper). Do not defer outbound specs to a later step.
- Commons template parity:
  - `OpenTelemetryConfig.initialize()` should be non-async unless it contains a real `await`.
  - `HeadersInterceptor` should type `Request` explicitly (`getRequest<Request>()`) to avoid unsafe `any` access.

Auth-specific template selection:

- If module is `auth` and requires reCAPTCHA, scaffold from `.agent/templates/template-module-auth/with-re-captcha/`.
- If module is `auth` and does not require reCAPTCHA, scaffold from `.agent/templates/template-module-auth/without-re-captcha/`.
- For auth modules, scaffold `commons/libs/crypto/*` and install `crypto-js`.
- For auth modules that use token core, scaffold `commons/token/*` from `template-commons` and consume it as shared commons (no hexagonal regeneration for token).
- In auth templates, import token dependencies from `../commons/token/*` (module scope) or `../../../../../commons/token/*` (deep adapters), not from `../token/*`.
- When `commons/token` is used by generated modules, ensure `TokenModule` is registered in `app.module.ts` imports and in feature module imports that require it.
- For basic-data dependency, scaffold `commons/basic-data/*` from `template-commons` and consume it as shared commons (no hexagonal regeneration for basic-data).
- In module templates, import basic-data dependencies from `../commons/basic-data/*` (module scope) or `../../../../../commons/basic-data/*` (deep adapters), not from feature-local regenerated components.
- When `commons/basic-data` is used by generated modules, ensure `BasicDataModule` is registered in `app.module.ts` imports and in feature module imports that require it.
- For non-auth modules, do not scaffold/import `commons/libs/crypto/*` unless explicitly requested.

OTC-specific template selection:

- If module is `otc`, scaffold from `.agent/templates/template-module-otc/otc/*`.
- OTC generation must create the full module tree in one pass:
  - `otc/otc.module.ts`
  - `otc/generate/*`
  - `otc/validate/*`
- Do not scaffold only one OTC submodule when the request is "crear módulo otc" unless the user explicitly asks for partial generation.

Never generate unused technology folders.

After module generation and implementation:

- Run the mandatory post-generation validation loop defined in `.agent/tools/execution-policies.md`
- Smoke test created endpoint(s); if external APIs are unavailable and Postman MCP is available, validate using a Postman collection + Mock Server in `My Workspace`
- Do not create local filesystem mock servers for external dependencies as the default path (`mocks/*`, inline mock apps); Postman MCP mock flow is the required default when mocking is needed.
- Ensure validation commands are executed from the microservice directory containing `package.json`
- Validate outbound adapter logging helper usage (`httpLogger` / `internalLogger`) before delivery
