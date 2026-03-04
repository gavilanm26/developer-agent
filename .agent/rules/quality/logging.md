---
trigger: always_on
---

# Logging Rules

Logging allowed ONLY in:

infrastructure/adapters/outbound/**

Prerequisite (mandatory):

- If a generated adapter uses `httpLogger` or `internalLogger`, the project must contain the shared commons logging files.
- Validate existence of `src/commons/http-logger/*` before generating adapter code that imports them.
- If missing, scaffold from `.agent/templates/template-commons/http-logger/*` first.
- If OTel bootstrap is required for the microservice, also scaffold `.agent/templates/template-commons/otel.config.ts.tpl` into `src/commons/otel.config.ts`.

Rules:

- Inject NestJS Logger
- Use `httpLogger` for outbound HTTP integrations that call external services via HTTP clients/observables
- Use internalLogger for DB, Redis, engines
- Outbound `clients/*` adapters must not log raw success/error payloads directly with `logger.log/error` when `httpLogger` applies
- Outbound `repositories/*`, `cache/*`, and `engines/*` adapters must use `internalLogger` (when logging is required)
- Direct `Logger` calls in outbound adapters are only for bootstrapping/diagnostic messages that are not request-operation traces
- If an outbound adapter is generated as a temporary stub, the agent must still choose the correct logging strategy (`httpLogger` vs `internalLogger`) or explicitly omit logging (do not fallback to ad-hoc direct request logs)
- Never log in:
  - domain
  - application
  - controllers

Validation checklist (mandatory for generated/modified outbound adapters):

- `outbound/clients/*`: verify `httpLogger` usage when using HTTP integrations
- `outbound/repositories/*`, `outbound/cache/*`, `outbound/engines/*`: verify `internalLogger` usage when operation logging exists
- Reject delivery if request-operation logs are implemented with plain `logger.log/error/warn` instead of the required helper
