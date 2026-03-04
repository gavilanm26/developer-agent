---
trigger: always_on
---

# Layering Rules

The system must follow strict Hexagonal Architecture.

--------------------------------------------------
APPLICATION LAYER
--------------------------------------------------

Contains:

- ports (inbound contracts)
- use-cases
- services (orchestrators)
- gateways
- dto (pure, no decorators)

Rules:

- No NestJS decorators
- No infrastructure imports
- Only depends on domain ports
- Controllers depend only on inbound contracts or usecases

--------------------------------------------------
DOMAIN LAYER
--------------------------------------------------

Contains:

- entities
- value-objects
- enums
- interfaces
- ports (OUTBOUND ONLY)

Rules:

- No framework imports
- No infrastructure knowledge
- Ports define outbound contracts only
- Default contract type: abstract classes
- Domain (`domain/**`) must never import from `application/**` or `infrastructure/**`.
- Domain ports must use domain models/contracts (`domain/models`, `domain/entities`, `domain/interfaces`) instead of application DTOs.

--------------------------------------------------
INFRASTRUCTURE LAYER
--------------------------------------------------

Contains:

- inbound adapters (http, messaging, grpc)
- outbound adapters (repositories, cache, clients, engines)
- persistence (schemas, migrations)

Rules:

- Adapters implement domain ports
- Adapters must use `implements` for abstract-class contracts (do not use `extends` for ports)
- Logging only in outbound adapters
- Redis belongs in outbound/cache
- Persistence only for DB schemas
- Infrastructure adapters can depend on domain contracts and application orchestrators/ports, but outbound adapter method signatures must match domain-port models (not application DTOs).
