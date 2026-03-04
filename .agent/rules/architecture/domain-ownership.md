---
trigger: always_on
---

# Domain Ownership Rules

For customer-owned domains (for example: products, savings accounts, loans, cards, gateway payments), ownership must be modeled from the first version.

Mandatory ownership modeling:

- Every customer-owned aggregate must include an owner identity in domain/application/infrastructure layers.
- Preferred owner key is `customerId` when an upstream customer identity exists.
- If `customerId` is unavailable by business design, require document-based identity at minimum:
  - `documentType`
  - `documentNumber`
- For HTTP DTOs, when `documentType` is used, type it with `TypeOfDocuments` from `src/commons/enums/type-of-documents.enum`.
- Ownership data is not optional for create operations in customer-owned domains.

Contract and data shape requirements:

- Domain entity must include ownership fields.
- Application request/response DTOs must include ownership fields.
- Inbound HTTP DTOs must validate ownership fields (`class-validator`).
- Persistence schema/document must store ownership fields.
- Persistence should define query-friendly ownership indexes when the technology supports it.

Behavior requirements:

- List/search endpoints for customer-owned resources should support owner-scoped filtering when the API contract explicitly requires it.
- If the user requests owner-agnostic listing (for example `GET /resource` for full list), do not force owner filter endpoints by default.
- Access to a single resource (`GET by id`, `PATCH`, `DELETE`) must preserve ownership invariants in application flow.
- For simple owner filters (`documentType` + `documentNumber`), prefer direct query parameters over extra query DTO classes.
- Enforce the pair invariant (`both or none`) in application/use-case validation when query DTO is not required.

Analytical guardrail:

- During capability detection, classify whether the feature is customer-owned.
- If customer-owned, generate owner-aware contracts by default, unless the user explicitly requests otherwise.
