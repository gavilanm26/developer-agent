---
trigger: always_on
---

# Hexagonal Architecture Generation Rule (Microservices)

## Purpose

This rule defines how modules must be generated using **Hexagonal Architecture (Ports & Adapters)**.
The generator must create **only the folders and files required by the feature**, avoiding unused technologies (Redis, Kafka, Mongo, gRPC, etc.) unless explicitly requested.

---

# Base Structure

```
feature-module
 ├── application
 ├── domain
 ├── infrastructure
 └── feature.module.ts
```

Only create subfolders when the feature requires them.

---

# Application Layer

Responsible for orchestration of business flows.

```
application
 ├── dto
 │     ├── input.dto.ts
 │     └── output.dto.ts
 │
 ├── commands
 │     └── *.command.ts
 │
 ├── queries
 │     └── *.query.ts
 │
 ├── use-cases
 │     └── *.usecase.ts
 │
 └── services
       └── *.service.ts
```

### Responsibilities

**dto/**

* Contracts used internally by use cases.
* Must NOT contain framework decorators.

**commands/**

* Represent write operations (CQRS write model).

**queries/**

* Represent read operations (CQRS read model).

**use-cases/**

* Orchestrate the business flow.
* Call domain ports.
* Must NOT access infrastructure directly.

**services/**

* Shared application logic reusable across multiple use cases.

---

# Domain Layer

Contains business logic independent from frameworks.

```
domain
 ├── entities
 │     └── *.entity.ts
 │
 ├── value-objects
 │     └── *.vo.ts
 │
 ├── criteria
 │     └── *.criteria.ts
 │
 └── ports
       ├── *.repository.port.ts
       ├── *.service.port.ts
       ├── *.engine.port.ts
       └── *.client.port.ts
```

### Responsibilities

**entities/**

* Represent core business models.
* May include domain rules.

**value-objects/**

* Immutable business value representations.

**criteria/**

* Objects used for searches and filtering.

**ports/**

* Contracts implemented by infrastructure.
* Must NOT depend on frameworks.

---

# Infrastructure Layer

Contains framework-specific implementations.

```
infrastructure
 ├── adapters
 └── persistence
```

---

## Inbound Adapters

External entry points into the system.

```
adapters/inbound
 ├── http
 │     ├── *.controller.ts
 │     └── dto
 │           └── *.http.dto.ts
 │
 ├── messaging
 │     └── *.consumer.ts
 │
 └── grpc
       └── *.grpc.controller.ts
```

Create only what is required by the feature.

**http/dto/**

* HTTP validation DTOs (class-validator).
* Must not be used inside domain or application.

---

## Outbound Adapters

Implement domain ports.

```
adapters/outbound
 ├── repositories
 │     └── *.repository.impl.ts
 │
 ├── clients
 │     └── *.client.ts
 │
 ├── engines
 │     └── *.engine.adapter.ts
 │
 ├── messaging
 │     └── *.publisher.ts
 │
 └── mappers
       ├── inbound.mapper.ts
       └── outbound.mapper.ts
```

### Responsibilities

**repositories/**

* Implement persistence ports (Mongo, SQL, Redis).

**clients/**

* External API integrations.

**engines/**

* Rule engines (Zen Engine, decision engines).

**mappers/**

* Convert between DTOs, entities, and persistence models.

---

## Persistence

Only create persistence structures when database storage is required.

```
persistence
 ├── schemas
 │     └── *.schema.ts
 │
 └── migrations
       └── *.migration.ts
```

---

# Module File

```
feature.module.ts
```

Responsibilities:

* Dependency injection wiring
* Port → Adapter bindings
* External module imports

---

# Generation Rules

1. Create only folders required by the feature.
2. Do not generate Redis, Kafka, Mongo, SQL, gRPC or messaging structures unless explicitly requested.
3. Domain must remain framework-agnostic.
4. Application must never access infrastructure directly.
5. Controllers must never contain business logic.
6. Use Cases must orchestrate all feature operations.
7. Adapters must implement domain ports.
8. Persistence must be isolated inside infrastructure.

---

# Execution Flow (Reference)

```
External Request
   ↓
Inbound Adapter (Controller / Consumer)
   ↓
Mapper (HTTP DTO → Application DTO)
   ↓
Application UseCase
   ↓
Domain Ports
   ↓
Outbound Adapter (Repository / Client / Engine)
   ↓
Infrastructure (DB / API / Redis / Engine)
```

---

# Final Instruction for Generator

When generating a feature:

* Analyze the requested capability
* Create only the necessary folders
* Respect the hexagonal separation strictly
* Never mix infrastructure with domain logic
* Keep the architecture minimal but extensible
