---
trigger: always_on
---

# Testing Rules

Generate tests only for components that exist in the requested module/capability set.

Mandatory baseline:

- `feature.module.spec.ts` (for generated modules)
- `*.usecase.spec.ts` for each generated use case
- `*.impl.service.spec.ts` for application orchestrator service when generated

Conditional tests (generate only if the component exists):

- `*.controller.spec.ts` for HTTP inbound controllers
- `*.grpc.controller.spec.ts` for gRPC inbound controllers
- `*.consumer.spec.ts` for messaging consumers
- `*.repository.impl.spec.ts` for repository adapters
- `*.cache.impl.spec.ts` for cache adapters
- `*.rest.client.spec.ts` / `*.grpc.client.spec.ts` / `*.soap.client.spec.ts` for outbound clients
- `*.publisher.spec.ts` for outbound messaging publishers
- `*.engine.adapter.spec.ts` for engine adapters
- `*.mapper.spec.ts` for infrastructure mappers if they contain logic worth unit testing
- `*.adapter.spec.ts` only when no more specific suffix convention exists
- `*.service.spec.ts` for application orchestrator services (if generated)

Explicit exclusions (do not generate by default):

- `src/main.spec.ts`
- `src/app.module.spec.ts`
- `*.http.dto.spec.ts` for generated HTTP DTOs (even when they use `class-validator`)

Rules:

- Mock all injected dependencies
- No real DB
- No real HTTP
- No real Redis
- Cover success and failure paths
- Do not generate empty spec files
- Test generation must follow capability detection and minimal scaffolding rules
- For outbound integrations (REST/gRPC/SOAP, Mongo repositories with request/document shaping), generate mapper unit tests as part of the default set because mappers contain business-critical request/header/url/document assembly logic
- Outbound mandatory minimum when components exist (do not skip):
  - each generated outbound REST client must have `*.rest.client.spec.ts`
  - each generated outbound repository adapter (Mongo/SQL/etc.) must have `*.repository.impl.spec.ts`
  - each generated outbound cache adapter must have `*.cache.impl.spec.ts`
  - each generated outbound mapper used by clients/repositories must have `*.mapper.spec.ts`
  - absence of these specs is a generation defect and the task is not complete
- Prefer colocated specs next to implementation files unless a project profile defines another test layout
- HTTP controller tests should mock the inbound application port (`application/ports/*.usecase.ts`) instead of mocking individual use cases directly
- Do not generate standalone HTTP DTO unit tests by default; validate DTO behavior indirectly through controller/e2e validation only when needed by the task
- Mock external HTTP/Redis/Mongo only in tests/specs. Do not introduce mock branches in production adapters to satisfy local smoke tests.
- If `npm run test:cov` fails, the agent must fix tests/code and rerun until passing (when execution is possible)
