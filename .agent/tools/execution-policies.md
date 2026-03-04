# Execution Policies

Agents must:

- Always use Nest CLI for project/module creation.
- For new microservices, execute `nest new <project-name> -p npm` before template/application scaffolding.
- If the user requests in-place microservice creation in the current repository/root, execute `nest new . -p npm` (only when the directory is empty/safe).
- For new modules, execute `nest g mo modules/<module-name>` before creating module internals.
- Remove unused default Nest files.
- Ensure strict TypeScript configuration.
- Avoid manual folder creation when CLI is available.
- Use `.agent/templates/` as the local template source for shared scaffolding artifacts.
- For backend bootstrap config files, use global templates:
  - `.agent/templates/global/package.json.tpl`
  - `.agent/templates/global/tsconfig.json.tpl`
  - `.agent/templates/global/jest.config.js.tpl`
- Resolve module alias placeholders dynamically (for example `{{PRIMARY_MODULE_ALIAS}} -> products`) and avoid hardcoded alias names when module name differs.
- Resolve `{{SERVICE_NAME}}` in `package.json.tpl` using the target microservice name.
- Keep Jest config outside `package.json`; if `package.json` contains a root `jest` object after scaffolding, remove it and keep `jest.config.js` as source of truth.
- Keep `package.json.tpl` dependency sets baseline-only; install capability-specific dependencies only when required by detected capabilities.
- Do not keep clearly unused capability packages in generated `package.json` (for example `ioredis` / `@types/ioredis` when Redis capability is not selected).
- Validate `src/commons/*` prerequisites before generating adapters/controllers that import shared commons utilities.
- When using templates, render placeholders and remove the `.tpl` suffix in output files.
- Copy only the template files required by detected capabilities (do not dump entire template packs by default).
- Prefer `.agent/tools/scripts/render-template-commons.sh` for selective `template-commons` (superset commons) copy/render operations.
- Prefer `.agent/tools/scripts/render-env-from-template.sh` to generate `.env` / `.env.example` from `.agent/templates/global/.env.tpl` with capability filtering.
- Do not dump all template env vars by default; include only variables required by detected capabilities and keep template values unchanged.
- Import path policy for generated code:
  - Prefer absolute alias imports (`@app/*`, `@commons/*`, `@modules/*`, `@<module>/*`).
  - Allow short relative imports in `*.module.ts` wiring files.
- `commons/token/*` from `template-commons` is a shared commons artifact and must remain template-shaped (do not scaffold an extra hexagonal `token` module around it).
- If `commons/token/*` is selected, add `TokenModule` (`commons/token/token.module`) to `app.module.ts` imports and to feature modules that inject `TokenAdapter`.
- `commons/basic-data/*` from `template-commons` is a shared commons artifact and must remain template-shaped (do not scaffold an extra hexagonal `basic-data` module around it).
- If `commons/basic-data/*` is selected, add `BasicDataModule` (`commons/basic-data/basic-data.module`) to `app.module.ts` imports and to feature modules that inject `GetBasicDataImplAdapter`.
- Dependency installation policy for new microservices:
  - `nest new <project-name> -p npm` already performs dependency installation by default.
  - Do not run a redundant `npm install` immediately after a successful `nest new`.
  - Run `npm install` only as recovery when the initial installation failed or was interrupted.
  - Consider `nest new` successful only after the CLI prints `Successfully created project <project-name>`.
  - Do not interrupt `nest new` while installation is in progress; wait for completion output.
  - If `nest new` was interrupted after scaffold file creation, run recovery install in the project directory (`npm install`) using escalation when network is required.
- Install dependencies before runtime/test validation (`npm install`) only when they are not already installed for the target microservice.
- Do not default to `--skip-install` on `nest new`; use it only with explicit environment/network blocker and report that blocker.
- For restricted/offline environments, prefer a fail-fast precheck before `nest new` install stage (for example `npm ping` with short timeout and temporary cache).
- If the precheck confirms npm registry/network is unavailable, it is allowed to switch to `nest new <project-name> -p npm --skip-install` and continue scaffolding without waiting on a blocked install.
- Escalation policy for network-required commands:
  - In environments with restricted sandbox networking, request `require_escalated` proactively for commands that need npm registry access (for example `nest new <project-name> -p npm`, `npm install`, `npm ping`).
  - If a required command fails due to sandbox/network restrictions (for example npm registry access), request out-of-sandbox execution using `require_escalated`.
  - Include a short justification question to the user and rerun the same command after approval.
  - When the client supports persistent prefix approvals, propose a narrow prefix rule for repeated install/validation commands.
  - Do not silently skip mandatory validation/install steps when escalation is feasible and not yet requested.
- Install capability-specific dependencies before generating code that imports them (for example `@nestjs/axios` for REST clients, OTel packages for `OpenTelemetryConfig`).
- Validate project compiles after scaffolding.
- Resolve the target execution directory before running commands (`npm`, `nest`, tests, curl setup). Do not assume repository root is the microservice root.
- Before delivery, run project formatting/lint autofix commands when available (prefer package scripts such as `npm run lint` when it includes `--fix` and `npm run format`) and resolve avoidable ESLint/format issues in modified/generated code.
- For features with external API dependencies, prefer Postman MCP (collection + mock server) for integration validation when the real external API is unavailable.
- Postman MCP mock creation is conditional (not default). Use it only when external API integration is required by the task and the real API details/environment are not available for validation.
- External API code parity policy:
  - Do not fork outbound client implementation for mock vs real integrations.
  - Keep one outbound `RestClient` implementation and switch target host only through environment variables (for example `APICOREURL`).
  - During mock validation, configure Postman Mock Server URL in environment variables instead of generating mock-specific adapter code.
- Do not create local filesystem mock servers (`mocks/*`, ad-hoc express/http mock apps) as the default substitute for external API validation when Postman MCP flow applies.
- Do not create inbound mock controllers/routes inside the target microservice to simulate external systems unless the user explicitly requests in-service mock endpoints.
- When creating Postman mock collections, if requests reference URL variables (for example `{{mockBase}}`), define the collection variable and set it to the generated Mock Server base URL in the same task.
- Do not create Postman artifacts (collection/mock/environment) by default when the task has no external API integration requirement and the user did not explicitly request Postman artifacts.
- If Postman MCP is used due to external API integration validation needs or explicit user request, create/update a Postman API collection with all inbound endpoints created or modified by the task (include required headers and sample payloads when applicable).
- If Postman MCP is used due to external API integration validation needs or explicit user request, create/update a Postman Environment with the variables needed to execute the collection (for example `serviceBaseUrl`, `mockBase`, resource ids, and common header values).
- If endpoints are created/updated in Postman as part of the task, create/update Postman tests (request test scripts/assertions) for functional validation; do not leave endpoint requests as request-only artifacts when functional validation is claimed.
- When defining Postman base URL variables, avoid invalid URL composition and use a deterministic convention:
- `serviceBaseUrl` must be a full URL including scheme (for example `http://localhost:3000`) and requests must use `{{serviceBaseUrl}}/...` without prepending another scheme.
- `mockBase` should also be stored as a full URL including scheme (for example `https://<mock-id>.mock.pstmn.io`) and requests should use `{{mockBase}}/...` without prepending another scheme.

## Post-Generation Validation Loop (Mandatory)

After implementing or modifying a microservice/module, the agent must run this loop before delivery:

0. Resolve execution context:
   - Identify the microservice directory (must contain `package.json`)
   - Run `npm`/Nest/test commands from that directory, not from the policy repo root unless it is a Node project

1. Start service in dev mode:
   - Run `npm run start:dev`
   - Validate startup has no runtime/compilation errors
   - If errors exist, stop, fix code/config, and retry (loop until startup is clean)
   - This step is blocking: do not continue to delivery while startup has unresolved errors
   - If startup depends on unavailable infrastructure (DB/Redis/external API), use the real project configuration and report blockers if local infra is unavailable
- If the environment blocks binding to the default port, retry with an alternate port (for example `PORT=3101`) and/or required permissions
- If the alternate port is already in use (`EADDRINUSE`), choose another port and retry (for example `3102`, `3103`, ...)

2. Validate automated tests and coverage:
   - Run structural test pairing precheck first:
     - `.agent/tools/scripts/verify-generated-tests.sh <microservice-directory>`
     - If precheck fails (for example outbound adapters without paired specs), generate/fix missing tests before continuing.
   - Run `npm run test:cov`
   - If tests fail, fix and rerun (loop until tests pass)
   - If coverage is below the configured minimum (95% global and 95% on generated/modified module scope), add/improve tests and rerun (loop until coverage passes)
   - Do not rely on shared `commons` tests to mask low coverage in the generated module
   - Recommended strict sequence:
     - `npm test` (all unit specs created for the task)
     - `npm run test:cov`
   - Both test steps are blocking when execution is possible: do not continue to delivery while tests are failing.

2.5. Validate formatting and lint quality:
   - Run project formatting/lint scripts from the microservice directory when available (at minimum `npm run lint`; also `npm run format` if the project defines it)
   - If lint/format reports issues that can be auto-fixed, apply the fixes and rerun until clean when execution is possible
   - If non-auto-fix lint issues remain, report them explicitly and do not claim code is fully lint-clean

3. Validate generated endpoint behavior:
   - Exercise the created endpoint(s) with a real request (smoke test)
   - If the task creates or modifies multiple inbound endpoints and the user requests endpoint validation/guarantees, execute and verify each created/modified inbound endpoint (not just one smoke test)
   - If Postman MCP is used due to external API integration validation needs or explicit user request, ensure the Postman API collection includes all inbound endpoints created/modified by the task before delivery (not only the smoke-tested endpoint)
   - If Postman MCP is used due to external API integration validation needs or explicit user request, ensure a Postman Environment exists and contains the variables required to execute those requests
   - If Postman MCP is used due to external API integration validation needs or explicit user request, run the Postman collection(s) with `runCollection` when execution is possible and verify there are no failed requests due to malformed URLs/variables
   - Before `runCollection`, validate that the configured `serviceBaseUrl` is reachable from the Postman execution context.
   - If `serviceBaseUrl` points to `localhost`/private network and Postman runner cannot reach it, mark Postman endpoint execution as `not executable in current environment` and use local smoke validation (for example `curl`) while reporting the limitation explicitly.
   - If endpoints are created/updated in Postman as part of the task, treat Postman `runCollection` execution as the primary validation path for those endpoints; `curl` may be used only as supplemental diagnostics and does not replace the Postman execution requirement
   - `runCollection` alone is not sufficient as endpoint behavior proof when requests have no assertions; also verify expected status codes/body outcomes from real endpoint executions (success paths and relevant failure paths)
   - When endpoints are created/updated in Postman as part of the task, add assertions/tests to the relevant Postman requests before running `runCollection`
   - If `runCollection` reports fewer executed requests than the number of intended endpoint requests in the collection, or reports zero assertions despite configured test scripts, treat Postman validation as inconclusive and report the MCP/tool limitation explicitly before using any supplemental validation
   - Minimum Postman functional test coverage for the modified endpoint scope (when execution is possible):
   - For each validated endpoint request: expected status code assertion
   - For success-path requests: assertions for key response fields/shape and content type when applicable
   - For create/update flows: capture identifiers from responses into variables when needed for downstream requests
   - For list/get/delete/update flows: include assertions that confirm the intended effect (for example item exists, item changed, item deleted)
   - Include relevant negative-path requests/assertions for the modified endpoint scope when behavior is known and feasible (for example validation error, not found, ineligible customer, invalid payload)
   - If a requested negative path cannot be asserted reliably in the current environment, report that limitation explicitly in delivery output
   - Confirm expected response behavior (success and relevant failure path when applicable)
   - Confirm logs are emitted according to logging rules (only in allowed layers/adapters and using required logger helpers)
   - If the service is running with elevated permissions/network namespace constraints, run smoke-test requests in the same execution context
   - Verify generated outbound adapters use the correct helper (`httpLogger` or `internalLogger`) in code, not only that logs exist at runtime
   - If the feature depends on an external API and the real API is unavailable:
     - detect whether Postman MCP is available in the current session
     - if available, create/update a collection in `My Workspace` and create a Mock Server for the external API endpoints needed by the feature
     - if Postman MCP is being used for this validation, create/update the corresponding Postman Environment for executing inbound endpoint requests and mock-backed requests
     - if collection requests use a URL variable such as `{{mockBase}}`, persist that variable in the collection with the generated Mock Server base URL
     - if Postman Mock matching returns persistent `mockRequestNotFound` after deterministic setup (method/path/body/example), report Postman mock matching as a tooling limitation and continue with an explicit fallback mock strategy that keeps production architecture intact
     - run integration validation against the Postman Mock Server
     - if Postman MCP is not available in the current session, report the limitation and use fallback local/manual validation where possible
   - Do not mark endpoint validation as complete if Postman MCP path is required by rules but was skipped.
   - Postman MCP decision matrix:
     - New microservice: create mock only if the requested capabilities include external API integration and no real API details/environment are provided
     - New module: create mock only if the requested module includes external API integration and no real API details/environment are provided
     - Refactor existing module:
       - if the module already has an external integration and the task is refactor-only, do not create a mock by default
       - if the task adds a new external integration and no real API details/environment are provided, create a mock
       - if no external integration is requested, do nothing

4. Delivery output:
   - If Postman MCP was used, provide:
     - Workspace name
     - Collection name
     - Request names/endpoints created
     - Explicit note that all inbound endpoints created/modified by the task were included in the Postman API collection
     - Environment name
     - Environment variables created/updated
     - Mock Server base URL
     - Collection variables created/updated for the mock (at minimum `mockBase` when used)
     - Reason Postman MCP was used (`external API integration validation` or `explicit user request`)
     - Postman `runCollection` execution status (passed / failed / not executable in environment) for each created/updated collection
     - Postman tests/assertions coverage summary (what was asserted per endpoint and which negative paths were included/excluded)
     - Real endpoint validation status per endpoint (verified / not verified) and the reason for any endpoint not verified
     - If endpoints were created/updated in Postman: explicit confirmation that Postman (not only `curl`) was used for endpoint validation
   - Otherwise provide the final `curl` command(s) for manual verification by the user
   - Report any assumptions (port, headers, auth tokens, seed data)
   - Report formatting/lint execution status (`lint` / `format`) and any remaining non-auto-fix issues

Rules:

- Do not deliver scaffolding as "done" without running the validation loop when execution is possible in the environment.
- Pre-delivery checklist is mandatory and must be explicitly satisfied in order:
  1) `start:dev` validated (or explicit blocker)
  2) structural spec precheck validated (or explicit blocker)
  3) `npm test` validated (or explicit blocker)
  4) `npm run test:cov` validated (or explicit blocker)
  5) endpoint validation validated (or explicit blocker)
- If execution is not possible (missing dependencies, restricted environment, unavailable services), report the blocker explicitly and state what was not validated.
- If dependency installation/execution is blocked by network restrictions, run a static import-integrity check on generated/modified files (resolve relative imports to existing files) and fix broken paths before delivery.
- If command execution is blocked, delivery output must enumerate each pending mandatory loop step (`start:dev`, `test:cov`, coverage threshold, endpoint validation) as `not executed` with explicit reason.
- If structural precheck command execution is blocked, delivery output must explicitly mark outbound spec-pair validation as `not executed` with reason.
- In restricted/offline environments, prefer explicit install steps and commands that fail fast (avoid hidden long-running installs with no feedback).
- If the user home npm cache/log directory is not writable, use a temporary external cache path (for example `npm_config_cache=/tmp/codex-npm-cache`) for install/test commands.
- Do not create `.npm-cache` folders inside the generated microservice as part of scaffolding output.
- Prefer visible install output (`tty` and/or verbose mode) when dependency installation appears stalled.
- Do not modify generated production code to add fake/in-memory infra just to pass local validation.
- If Mongo/Redis/external infra is required and unavailable, report the blocker (or ask the user to enable local infra) rather than generating mock branches in adapters/modules.
- If Postman MCP was expected but unavailable due session/tooling visibility, report that explicitly and do not pretend the collection/mock server was created.
