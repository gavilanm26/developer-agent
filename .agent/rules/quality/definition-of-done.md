---
trigger: always_on
---

# Definition Of Done

A task is not complete until all applicable items below are satisfied.

Implementation

- Generated/refactored code follows the active architecture rules (hexagonal layers respected)
- Ports in `application/ports` and `domain/ports` are abstract classes
- Concrete classes fulfilling ports use `implements` for the port contract (no `extends` for port contracts)
- Controllers depend on inbound application ports, not directly on infrastructure adapters
- Controllers contain transport concerns only (no business orchestration/payload composition)
- Outbound integrations use infrastructure mappers for URL/header/request/document assembly when applicable
- Outbound clients keep code parity between real and mock environments (same `RestClient` path); integration target changes only via env vars (for example `APICOREURL`)
- Mongo repository adapters keep persistence-only responsibilities (query/filter/mapping/logging), without embedding domain business decisions by default
- For customer-owned domains, owner identity is modeled end-to-end (entity, DTOs, inbound contracts, persistence); owner-scoped retrieval is implemented when requested by API contract
- Logging helpers are used correctly:
  - `httpLogger` in outbound HTTP clients
  - `internalLogger` in repository/cache/engine adapters when logging operations

Scaffolding / Templates

- Only required capabilities were generated
- Shared `commons` prerequisites were scaffolded when required
- No unresolved `{{PLACEHOLDER}}` values remain in generated source
- No fake/in-memory production adapters/modules were introduced to bypass missing infra
- No mock-specific outbound client logic exists in production code (`*MockClient`, inline fake responses, or mock-mode conditionals in `outbound/clients/*`)
- Redis cache ports/adapters use the default minimal contract (`get`/`set`) unless broader cache operations were explicitly requested
- Project `.env` (or `.env.example`) was generated/updated with project-standard local defaults when needed
- Redis `.env` defaults are explicit and non-empty when Redis capability is present (`INFRAREDISPASS=claveRedis` baseline unless the user provides another value)

Testing / Coverage

- Unit tests exist for all generated components required by capability rules
- Outbound adapter coverage is mandatory when outbound components exist:
  - `outbound/clients/*` => corresponding `*.rest.client.spec.ts` (or transport equivalent)
  - `outbound/repositories/*` => corresponding `*.repository.impl.spec.ts`
  - `outbound/cache/*` => corresponding `*.cache.impl.spec.ts`
  - `outbound/mappers/*` => corresponding `*.mapper.spec.ts`
  - if any outbound component exists without its paired spec, DoD is not met
- Test scope intentionally excludes generated `src/main.ts`, generated `src/app.module.ts`, and generated HTTP DTOs (`*.http.dto.ts`) unless the task explicitly requests those tests
- Mapper specs exist for outbound mappers (`set-data.mapper` or equivalent) when they contain assembly logic
- `npm run test:cov` passes
- Coverage threshold passes:
  - 95% overall
  - 95% on generated/modified module scope
- Coverage is not artificially satisfied by unrelated/shared tests while the target module remains under-covered

Runtime / Validation

- `npm run start:dev` was executed from the correct microservice directory
- Startup compilation/runtime was validated (or blocker was explicitly reported)
- Required infrastructure env vars are represented explicitly and are not replaced by silent hardcoded localhost fallbacks in production wiring (use clear marker values when env vars are missing)
- `main.ts` bootstrap uses standard backend wiring (otel init, grafana logger, global `AllExceptionsFilter`, global `ValidationPipe`, helmet, body size limits, ConfigService port)
- Redis provider/module configuration follows the standard pattern with `useValue: new Redis({...})` using `process.env.INFRAREDISHOST|INFRAREDISPORT|INFRAREDISPASS` and no hardcoded defaults
- Redis runtime defaults include `INFRAREDISTLS` in `.env` (`false` for local by default unless user requests TLS)
- Endpoint behavior was validated (or blocker was explicitly reported)
- Logs were validated in code and/or runtime for correct helper usage

External API Validation

- If external API integration is required and real API is unavailable:
  - Postman MCP was used to create/update collection + Mock Server in `My Workspace` when available, OR
  - MCP unavailability/blocker was explicitly reported
- If refactoring an existing module with already-existing external integration and no new external integration was requested, no unnecessary mock server was created

Delivery

- Final output includes either:
  - Postman collection/mock-server location details (if Postman MCP was used), or
  - `curl` examples (fallback)
- Assumptions/blockers were explicitly documented (ports, env vars, auth, unavailable infra)
