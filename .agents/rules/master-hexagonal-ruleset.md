---
trigger: always_on
---

# MASTER_HEXAGONAL_RULESET.md

**Universal Hexagonal Architecture Generation Ruleset (NestJS / Microservices)**

---

## Purpose

This document defines the **complete architecture generation standard** for all features built using Hexagonal Architecture (Ports & Adapters).

The generator must:

* Create **only required folders**
* Maintain strict **layer separation**
* Generate **ports before adapters**
* Wire dependencies automatically
* Follow deterministic naming conventions

---

# 1. Core Hexagonal Layers

```
feature-module
 ├── application
 ├── domain
 ├── infrastructure
 └── feature.module.ts
```

Only create subfolders required by the feature.

---

# 2. Application Layer Rules

```
application
 ├── dto
 ├── commands
 ├── queries
 ├── use-cases
 └── services
```

Responsibilities:

| Folder    | Responsibility                      |
| --------- | ----------------------------------- |
| dto       | Input/output contracts for usecases |
| commands  | Write operations                    |
| queries   | Read operations                     |
| use-cases | Orchestration logic                 |
| services  | Shared application logic            |

Rules:

* No framework decorators
* No persistence access
* Must call domain ports
* **STRICT:** DTOs must be in `application/dto`. Inline class definitions are FORBIDDEN.
* **STRICT:** Every class must have a `*.spec.ts` test file.

---

# 3. Domain Layer Rules

```
domain
 ├── entities
 ├── value-objects
 ├── criteria
 └── ports
```

Responsibilities:

| Folder        | Responsibility               |
| ------------- | ---------------------------- |
| entities      | Business models              |
| value-objects | Immutable business values    |
| criteria      | Search/filter objects        |
| ports         | Contracts for infrastructure |

Rules:

* Must not import frameworks
* Must not depend on infrastructure

---

# 4. Infrastructure Layer Rules

```
infrastructure
 ├── adapters
 └── persistence
```

Adapters are divided into inbound and outbound.

---

## Inbound Adapters

```
adapters/inbound
 ├── http
 ├── messaging
 └── grpc
```

Responsibilities:

| Component       | Role               |
| --------------- | ------------------ |
| controller      | Receives requests  |
| http dto        | Request validation |
| consumer        | Messaging input    |
| grpc controller | gRPC input         |

Controllers must not contain business logic.
**STRICT:** request bodies must use DTOs defined in `infrastructure/dto` or `application/dto`. Inline DTOs are FORBIDDEN.
**STRICT:** Infrastructure DTOs MUST use `class-validator` and `class-transformer` decorators for validation.
**STRICT:** Every controller must have a `*.spec.ts`.

---

## Outbound Adapters

```
adapters/outbound
 ├── repositories
 ├── clients
 ├── engines
 ├── messaging
 └── mappers
```

Responsibilities:

| Adapter      | Role                  |
| ------------ | --------------------- |
| repositories | Database persistence  |
| clients      | External APIs         |
| engines      | Rules engines         |
| messaging    | Event publishing      |
| mappers      | Object transformation |

---

# 5. Persistence Rules

Create only when storage is required.

```
persistence
 ├── schemas
 └── migrations
```

---

# 6. Naming Convention Rules

| Component          | Pattern                            |
| ------------------ | ---------------------------------- |
| Ports              | `*.port.ts`                        |
| Repository Adapter | `*.repository.impl.ts`             |
| Client Adapter     | `*.client.ts`                      |
| Engine Adapter     | `*.engine.adapter.ts`              |
| Entities           | `*.entity.ts`                      |
| Schemas            | `*.schema.ts`                      |
| UseCases           | `*.usecase.ts`                     |
| DTO HTTP           | `*.http.dto.ts`                    |
| DTO Application    | `*.input.dto.ts / *.output.dto.ts` |

Port tokens must follow:

```
ENTITY_TYPE_PORT
```

Example:

```
USER_REPOSITORY_PORT
PAYMENT_CLIENT_PORT
RULE_ENGINE_PORT
```

---

# 7. Dependency Injection Rules

All domain ports must be bound to adapters in `feature.module.ts`.

Example:

```
{
  provide: USER_REPOSITORY_PORT,
  useClass: MongoUserRepositoryAdapter
}
```

UseCases must inject **ports only**, never adapters.

---

# 8. Intelligent Scaffolding Rules

Before generation, detect required capabilities:

| Capability        | Generate                           |
| ----------------- | ---------------------------------- |
| HTTP endpoint     | inbound/http                       |
| Database          | repository port + adapter + schema |
| External API      | client port + adapter              |
| Rules engine      | engine port + adapter              |
| Cache             | cache repository + redis adapter   |
| Messaging publish | publisher adapter                  |
| Messaging consume | consumer adapter                   |

Never generate unused technologies.

---

# 9. Execution Flow Standard

```
External Request
   ↓
Inbound Adapter
   ↓
Mapper (HTTP → Application)
   ↓
UseCase
   ↓
Domain Ports
   ↓
Outbound Adapter
   ↓
Infrastructure Resource
```

---

# 10. Generator Mandatory Rules

The generator must:

1. Detect feature capabilities before scaffolding
2. Create minimal structure required
3. Generate ports before adapters
4. Wire ports automatically in module.ts
5. Never mix domain with infrastructure
6. Respect naming conventions strictly
7. Generate mappers only when transformation is required
8. Ensure architecture remains extensible and consistent
9. **STRICT:** Generate `*.spec.ts` for EVERY new file (Controller, Service, Repository, UseCase).
10. **STRICT:** Define DTOs in dedicated files, never inline.

---

# Final Instruction

When building any new feature:

* Analyze requested functionality
* Generate minimal hexagonal module
* Create ports first
* Create adapters only if required
* Bind ports to adapters automatically
* Follow naming and layering strictly

---

# 11. Imported Rules

@rule hexagonal-architecture-generation-rule.md
@rule hexagonal-binding-and-dependency-injection-rule.md
@rule hexagonal-naming-and-convention-rule.md
@rule intelligent-scaffolding-rule.md
@rule unit-test-generation-rule.md
@rule infrastructure-logging-rule.md