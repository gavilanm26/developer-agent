---
trigger: always_on
---

# Hexagonal Naming & Convention Rule (Ports, Adapters, DTOs, Schemas)

## Purpose

This rule defines the **mandatory naming conventions** for all files generated under Hexagonal Architecture to ensure consistency across microservices and automatic compatibility with dependency injection, adapters, and generators.

The generator must strictly follow these conventions when creating new modules.

---

# Port Naming Rules (Domain Layer)

All ports must end with `.port.ts`.

Examples:

| Type            | Naming                         |
| --------------- | ------------------------------ |
| Repository      | `user.repository.port.ts`      |
| External Client | `payment.client.port.ts`       |
| Engine          | `rules.engine.port.ts`         |
| Service         | `notification.service.port.ts` |

Each port must expose:

```
export const USER_REPOSITORY_PORT = 'USER_REPOSITORY_PORT';
export interface UserRepositoryPort {}
```

Token name must be:

```
<ENTITY>_<TYPE>_PORT
```

Example:

```
USER_REPOSITORY_PORT
RULE_ENGINE_PORT
PAYMENT_CLIENT_PORT
```

---

# Adapter Naming Rules (Infrastructure)

All adapters must end with `.adapter.ts` or `.repository.impl.ts`.

Examples:

| Purpose             | Naming                          |
| ------------------- | ------------------------------- |
| Repository Adapter  | `mongo-user.repository.impl.ts` |
| Redis Adapter       | `redis-user.repository.impl.ts` |
| REST Client Adapter | `payment.rest.client.ts`        |
| Rule Engine Adapter | `zen-rules.engine.adapter.ts`   |

---

# DTO Naming Rules

## Application DTO

Location:

```
application/dto
```

Naming:

```
create-user.input.dto.ts
create-user.output.dto.ts
```

Rules:

* Must not contain framework decorators
* Used only by usecases

---

## HTTP DTO

Location:

```
infrastructure/adapters/inbound/http/dto
```

Naming:

```
create-user.http.dto.ts
```

Rules:

* Uses class-validator
* Used only by controllers

---

# Entity Naming Rules

Location:

```
domain/entities
```

Naming:

```
user.entity.ts
payment.entity.ts
validation-rule.entity.ts
```

Rules:

* No framework imports
* Business logic only

---

# Schema Naming Rules

Location:

```
infrastructure/persistence/schemas
```

Naming:

```
user.schema.ts
validation-rule.schema.ts
transaction.schema.ts
```

Rules:

* Only persistence representation
* Never used directly by domain

---

# Mapper Naming Rules

Location:

```
infrastructure/adapters/outbound/mappers
```

Naming:

| Purpose                   | Naming               |
| ------------------------- | -------------------- |
| HTTP → Application        | `inbound.mapper.ts`  |
| Application → Persistence | `outbound.mapper.ts` |

---

# UseCase Naming Rules

Location:

```
application/use-cases
```

Naming:

```
create-user.usecase.ts
update-key.usecase.ts
evaluate-rule.usecase.ts
```

---

# Module Naming Rules

Every feature must expose:

```
feature-name.module.ts
```

Example:

```
create-key.module.ts
rules.module.ts
accounts.module.ts
```

---

# Generator Naming Rules

When generating files:

1. Always use kebab-case for filenames
2. Always use PascalCase for class names
3. Always use uppercase tokens for ports
4. Never mix DTO naming between HTTP and application layers
5. Never generate schema files inside domain
6. Always suffix repository adapters with `.repository.impl.ts`
7. Always suffix ports with `.port.ts`

---

# Example Naming Flow

Port:

```
user.repository.port.ts
```

Adapter:

```
mongo-user.repository.impl.ts
```

Binding:

```
provide: USER_REPOSITORY_PORT
useClass: MongoUserRepositoryAdapter
```

---

# Final Instruction for Generator

When creating a feature:

* Generate names strictly following these conventions
* Ensure all adapters map clearly to ports
* Keep naming deterministic to allow automatic module wiring
* Never create ambiguous filenames
