---
trigger: always_on
---

# Project Creation Rules

When creating a NEW MICROSERVICE:

If new directory:
    nest new <project-name>
    (Do not use `--skip-install` by default. Use it only when network/repository access is actually restricted and then run `npm install` explicitly as soon as possible.)
    (In restricted/offline environments, run a short npm connectivity precheck; if blocked, use `nest new <project-name> -p npm --skip-install` to avoid long waits.)
    (In restricted sandbox environments, request out-of-sandbox execution before running `nest new <project-name> -p npm` so dependency installation can complete with real network.)
    (Treat creation as successful only when Nest CLI prints `Successfully created project <project-name>`.)

If inside current repo:
    Prefer creating a subdirectory with Nest CLI (`nest new <project-name>`) unless the workspace is empty.
    Use `nest new .` only when the target directory is empty and safe to initialize.
    Do not assume repository root has `package.json`; validate the actual microservice root after scaffolding.
If the user explicitly requests creating the microservice in the current repository/root location, use:
    nest new . -p npm
and apply it only when the directory is empty/safe for in-place initialization.

API Gateway specialization (new microservice):

- If the request is specifically for an API Gateway microservice:
  - Use `.agent/templates/templates-gateway/*` as the base scaffold source
  - Do not use `template-module-components` as the primary base for API Gateway
  - Keep gateway bootstrap pattern (`main.ts`, `app.module.ts`, gateway commons, gateway dto) aligned with `templates-gateway`
  - Use endpoint templates from `.agent/templates/templates-gateway-endpoint/*` only when the request includes endpoint modules

After creation:

1. Remove default files:
   - app.controller.ts
   - app.service.ts
   - app.controller.spec.ts

2. Create base folder:
   src/modules

3. Enable strict TypeScript mode.
   - Scaffold `package.json` from `.agent/templates/global/package.json.tpl`.
   - Replace `{{SERVICE_NAME}}` with the target microservice name.
   - `package.json.tpl` must contain only baseline dependencies (no capability-specific packages by default).
   - Add capability-specific dependencies only when those capabilities are detected/required (for example Redis, Axios client, OTel, class-validator/class-transformer, helmet).
   - Keep Jest configuration in `jest.config.js` (or `test/jest-e2e.json`) and do not keep a `jest` root section inside `package.json`.
   - If `nest new` generated a `jest` section in `package.json`, remove it as part of template alignment.
   - For standard backend microservices, scaffold `tsconfig.json` from `.agent/templates/global/tsconfig.json.tpl`.
   - Replace `{{PRIMARY_MODULE_ALIAS}}` with the feature/module alias (for example `products`) when a module-specific alias is required.
   - Keep generic aliases enabled: `@app/*`, `@commons/*`, `@modules/*`.
   - Do not hardcode `@products/*` unless the target module alias is actually `products`.
   - Scaffold `jest.config.js` from `.agent/templates/global/jest.config.js.tpl` using the same alias replacement strategy.
4. Install capability-specific dependencies required by the requested technologies (HTTP clients, Redis, DB, OTel, messaging, etc.).
5. If logging/otel/interceptors are part of requested capabilities, scaffold only the required shared files/subfolders from:
   - `.agent/templates/template-commons/*`
   `template-commons` is the superset baseline; copy selectively per microservice capability.
   Example (selective copy): `http-logger/*`, `otel.config.ts.tpl`, `filters/*`, `exceptions/*`, `interceptor/*`, `health-check/*`
   Other optional commons packs: `constants/*`, `headers/*`, `libs/*`, `enums/*`, `https-agent/*`, `token/*`, `basic-data/*`
   Auth-only commons pack: `libs/crypto/*` (only when auth module/scenario requires encryption)
   - Prefer using `.agent/tools/scripts/render-template-commons.sh` for selective copy + render
   - For standard backend microservices (non API Gateway), `template-commons` is mandatory as commons source; do not scaffold commons from `templates-gateway/*`.
6. Render copied `*.tpl` files into real files (remove `.tpl`) before generating code that imports them.
   - For `token/*`, keep template shape under `src/commons/token/*` (module + adapter) and do not hexagonalize/regenerate that shared commons component.
   - If `token/*` is scaffolded, register `TokenModule` from `commons/token/token.module` in `src/app.module.ts` imports.
   - For `basic-data/*`, keep template shape under `src/commons/basic-data/*` (module + adapter) and do not hexagonalize/regenerate that shared commons component.
   - If `basic-data/*` is scaffolded, register `BasicDataModule` from `commons/basic-data/basic-data.module` in `src/app.module.ts` imports.
7. Dependency handling before validation loops:
   - If `nest new` completed successfully, do not run a redundant `npm install`.
   - Run `npm install` only when the initial scaffold installation failed/interrupted or when additional capability packages were added afterward.
   - If `nest new` is interrupted during installation, run `npm install` as recovery in the microservice directory (with escalation when registry access is restricted).
8. If requested capabilities include DB/Redis/external integrations, generate the real wiring (no fake/in-memory fallback code in production modules/adapters).
9. Generate a project `.env` file (or `.env.example`) from template with capability filtering.
   - Preferred source: `.agent/templates/global/.env.tpl`
   - Preferred helper: `.agent/tools/scripts/render-env-from-template.sh`
   - Include only variables required by detected capabilities/module requirements.
   - Keep selected variable values exactly as defined in `.env.tpl` (do not rewrite defaults while rendering).
   - Do not include unrelated `.env` variables when the corresponding capability is not requested.

Validation before code generation:

- Do not generate imports to `src/commons/*` unless those files exist or are scaffolded in the same operation.
- Do not leave unresolved template placeholders (for example `{{SERVICE_NAME}}`) in generated source files.
- For standard backend microservices (non API Gateway), do not scaffold root `src/dto/*` unless explicitly requested; default DTO placement is:
  - `application/dto/*`
  - `infrastructure/adapters/inbound/http/dto/*`
- Do not generate imports from packages that are not declared/installed for the selected capabilities.
- Do not run runtime/test commands from a directory without `package.json`.
- If dependency installation fails due network or environment restrictions, report the blocker and continue with non-executable validation only.
- If using shared commons templates, prefer the helper script to avoid inconsistent manual copy/render steps.
- For external API integration validation, do not create filesystem/local mock servers (`mocks/*`, ad-hoc express/http mock apps) as default validation artifacts; use Postman MCP mock flow when required by rules.
- For Mongo/Mongoose/Redis/external API capabilities, do not change generated production code to bypass missing infra. If local infra is unavailable during validation, report the blocker or request local services.
- Standard env names must be preserved when generating `.env` for Redis/Mongo:
  - `APPMONGOSTRING`
  - `INFRAREDISHOST`
  - `INFRAREDISPORT`
  - `INFRAREDISPASS`
  - `INFRAREDISTLS`
- Redis local defaults in generated `.env` must include non-empty password baseline:
  - `INFRAREDISPASS=claveRedis`
  - `INFRAREDISTLS=false`
10. For standard backend microservices, scaffold `src/main.ts` from `.agent/templates/template-module-components/wiring/main.ts.tpl` (global exception filter + otel init + grafana logger + validation + helmet + body limits).

Never skip CLI usage.
Never manually scaffold a project without Nest CLI.
Microservice creation command is mandatory and must be executed before any manual file/folder scaffolding:
    nest new <project-name> -p npm

After project scaffolding and feature implementation:

- Run the mandatory post-generation validation loop from `.agent/tools/execution-policies.md`
- Ensure the service can start with `npm run start:dev` before considering the task complete
- If external APIs are part of the requested capabilities and are unavailable locally, prefer Postman MCP collection + Mock Server validation (when available) before fallback manual validation
