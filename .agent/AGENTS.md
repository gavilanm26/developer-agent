# AGENTS.md

This repository follows a strict Global Hexagonal Architecture System.

All AI agents (Gemini, Codex, GPT, etc.) must:

---

## RULE LOADING ORDER (MANDATORY)

1. rules/architecture/\*
2. rules/conventions/\*
3. rules/quality/\*
4. rules/scaffolding/\*
5. Profile selection (exclusive):
   - `rules/profiles/default.md` by default
   - `rules/profiles/enterprise.md` only if explicitly requested
   - `rules/profiles/cqrs.md` only if explicitly requested
6. tools/execution-policies.md

---

## OPERATION DETECTION

Before generating code, detect if the request is:

- New Microservice
- New Module
- Extend Existing Module
- Refactor Existing Module
- Whether the target is an API Gateway microservice

Operation rule activation (mandatory):

- `New Microservice`
  - Apply full rule set
  - Entry point priority: `rules/scaffolding/project-creation.md`
  - Then apply module generation/capability detection, templates, validation loop, tests, and coverage
  - If microservice type is API Gateway, use gateway template flow:
    - base microservice scaffolding from `.agent/templates/templates-gateway/`
    - endpoint module scaffolding from `.agent/templates/templates-gateway-endpoint/` when requested

- `New Module`
  - Do not run project creation flow
  - Entry point priority: `rules/scaffolding/module-generation.md`
  - Apply capability detection, architecture/conventions/quality rules, templates, validation loop, tests, and coverage
  - Validate/add missing shared `commons` assets and dependencies only if required by the module capabilities
  - If target microservice is API Gateway, prefer `.agent/templates/templates-gateway-endpoint/` for module scaffolding

- `Extend Existing Module`
  - Treat as targeted module generation/change inside an existing feature
  - Preserve existing module behavior and structure where compatible, while applying current architecture/conventions/quality rules to new code
  - Apply validation loop and coverage requirements to the modified module scope

- `Refactor Existing Module`
  - Entry point priority: `rules/scaffolding/refactor-mode.md` (and `rules/architecture/*`)
  - Use scaffolding rules as target-structure guidance, not as permission to regenerate the module blindly
  - Preserve behavior/contracts unless the user explicitly requests breaking changes
  - Add/upgrade tests and coverage to meet current thresholds (95% global and 95% modified module scope) when execution is possible

---

## GLOBAL REQUIREMENTS

- Always use official NestJS CLI commands for project and module creation.
- CLI enforcement:
  - New microservice: `nest new <project-name> -p npm` must run first
  - New module: `nest g mo modules/<module-name>` must run first
  - `--skip-install` is allowed only with explicit network/environment blocker; it is not the default path
- Use `.agent/templates/` as the only approved local template source.
- API Gateway template policy:
  - `templates-gateway/*` only for creating new API Gateway microservices
  - `templates-gateway-endpoint/*` only for creating/extending modules inside API Gateway microservices
- Standard backend microservice policy:
  - ALWAYS use `.agent/templates/template-module-microservice/` explicitly as the canonical guide (and its README.md) whenever creating a NEW MODULE in a standard microservice. Do NOT guess folder names. Use UseCases, Models, and correct Port names according to this template.
  - Use `template-commons/*` as commons source for non-gateway microservices
  - Do not scaffold root `src/dto/*` by default in non-gateway microservices unless explicitly requested
- Always generate minimal required structure.
- Always generate corresponding test files.
- Never mix architectural layers.
- Prefer abstract classes as contracts (default profile).
- Never inject infrastructure adapters into application layer.
- Remove unused default Nest files after project creation.
- Enforce logging rules automatically.
- If a rule requires shared `commons` assets (logging/otel/interceptors), validate and scaffold them from `.agent/templates/template-commons/` first.
- `.env` generation must use `.agent/templates/global/.env.tpl` as source and include only variables required by detected capabilities/module needs.
- Selected `.env` variables must keep template values as-is (no default rewriting during render).
- For backend configuration files, use global templates:
  - `.agent/templates/global/package.json.tpl`
  - `.agent/templates/global/tsconfig.json.tpl`
  - `.agent/templates/global/jest.config.js.tpl`
- Module-specific aliases in tsconfig/jest templates must be dynamic (based on module name) and must not be hardcoded to `products` unless the module is `products`.
- Keep Jest configuration out of `package.json` (no root `jest` section); use `jest.config.js` template as the single source for unit-test config.
- `package.json` must not include capability dependencies that are not used by the requested/generated scope.
- Capability dependencies (for example Redis/Axios/OTel/validation/helmet) must be added only when required by detected capabilities.
- Prefer absolute alias imports in generated code; relative imports are allowed in `*.module.ts` wiring files.
- For `auth` module generation/refactor, use `.agent/templates/template-module-auth/` variants:
  - `with-re-captcha` when reCAPTCHA is required
  - `without-re-captcha` when reCAPTCHA is not required
- For `otc` module generation/refactor, use `.agent/templates/template-module-otc/otc/*` as the primary source and scaffold the full `otc` tree (`otc.module.ts`, `generate`, and `validate`) in one step.
- For `auth`, scaffold `commons/libs/crypto/*` and required deps; for non-auth modules, do not scaffold/import crypto unless explicitly requested.
- For token-core dependency, scaffold and use `commons/token/*` from `template-commons` as shared commons (do not create/extend a hexagonal `token` module structure).
- When `commons/token/*` is used, register `TokenModule` in `app.module.ts` and import it in feature modules that inject `TokenAdapter`.
- For basic-data dependency, scaffold and use `commons/basic-data/*` from `template-commons` as shared commons (do not create/extend a hexagonal `basic-data` module structure).
- When `commons/basic-data/*` is used, register `BasicDataModule` in `app.module.ts` and import it in feature modules that inject `GetBasicDataImplAdapter`.
- Keep architecture deterministic and production-ready.
- Validation order is mandatory: implementation -> `start:dev` -> tests/coverage -> endpoint validation.
- Before reporting completion, run code formatting/lint autofix in the target microservice/module when available (prefer the project scripts, e.g. `npm run lint` when it already includes `--fix`, and `npm run format` when present) and do not leave avoidable ESLint/format issues unresolved.
- If external APIs are unavailable during endpoint validation and Postman MCP is available, create/use a Postman collection + Mock Server in `My Workspace` before fallback manual validation.
- Do not create local filesystem mock servers (`mocks/*`, ad-hoc mock apps) as default artifacts when Postman MCP mock flow applies.
- If a Postman collection request uses variables for mock URLs (for example `{{mockBase}}`), always create the collection variable and assign the generated Mock Server base URL before reporting completion.
- Do not create Postman collections/mocks/environments by default for refactors, modules, or new microservices that do not include an external API integration requirement and do not explicitly request Postman artifacts.
- If Postman MCP is used because the task requires external API integration validation or the user explicitly requests Postman artifacts, create or update a Postman collection containing all inbound endpoints created or modified by the task (not only the endpoint used for the smoke test).
- If Postman MCP is used because the task requires external API integration validation or the user explicitly requests Postman artifacts, also create/update a Postman Environment with the variables required to run the collection (service base URL, mock base URL when used, ids/placeholders, and key headers).
- Do not report Postman validation as completed unless the created/updated Postman collections were executed with Postman (`runCollection`) or the execution limitation was explicitly reported.
- If endpoints are created/updated in Postman as part of the task, endpoint validation must be performed in Postman (MCP `runCollection`) and must not be replaced by `curl`-only validation except when Postman execution is unavailable (which must be reported explicitly).
- If endpoints are created/updated in Postman as part of the task, the agent must also create Postman tests/assertions for functional validation (not only requests), covering the feasible success paths and relevant error paths for the modified endpoint scope before reporting completion.
- Do not claim endpoint validation is complete for multiple endpoints unless each created/modified inbound endpoint was verified with real executions (or each omitted endpoint is explicitly listed as not verified with reason).
- Postman Mock Server usage is conditional by task type:
  - new microservice/new module: only when external API integration is requested and real API details/environment are not provided
  - refactor existing module: do not create a mock for already-existing integrations unless the task adds a new external integration and the real API details/environment are not provided
- For Exception Handling, ALWAYS configure `app.useGlobalFilters(new AllExceptionsFilter())` in `main.ts`. NEVER use the `@UseFilters()` decorator on individual controllers in `modules/`.
- For Domain Models in Orchestrator microservices, prefer `interface` for anemic payload typing/DTOs that don't require internal behavior or strict instantiation guards. Use `class` with `readonly` properties only for core orchestration state entities that require rigid encapsulation and constructor validation.

Only one profile should be active unless the user explicitly asks to combine profiles.
If profiles are combined, the agent must state the precedence before generating code.
