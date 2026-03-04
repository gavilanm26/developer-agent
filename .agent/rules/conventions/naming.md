---
trigger: always_on
---

# Naming Conventions

Files: kebab-case
Classes: PascalCase

Ports:
*.port.ts

Inbound use case contracts (application/ports):
*.usecase.ts

Repository adapters:
*.repository.impl.ts

Cache adapters:
*.cache.impl.ts

External API / client adapters:
- Preferred transport-specific names:
  - *.rest.client.ts
  - *.grpc.client.ts
  - *.soap.client.ts
- If transport is not relevant, use `*.client.impl.ts`

Engine adapters:
*.engine.adapter.ts

UseCases:
*.usecase.ts

Application services:
*.service.ts

Controllers:
*.controller.ts

gRPC inbound controllers:
*.grpc.controller.ts

Messaging consumers:
*.consumer.ts

Event publishers:
*.publisher.ts

HTTP DTO:
*.http.dto.ts

Application DTO:
*.request.dto.ts / *.response.dto.ts

Entities:
*.entity.ts

Interfaces:
*.interface.ts

Port rules:
- Ports in `application/ports` and `domain/ports` must be abstract classes (not TypeScript interfaces)
- Classes that fulfill port contracts must use `implements` with the abstract-class type (avoid `extends` for port contracts)
- If a shape contract is required, place it in the appropriate layer as `*.interface.ts` or `*.dto.ts`, not inside `ports/*`

Schemas:
*.schema.ts

Migrations:
*.migration.ts

Mappers:
*.mapper.ts

Mapper naming guidance:
- Prefer domain-specific names such as `set-data.mapper.ts` for outbound request/header/url/document assembly
- Avoid generic `helper` names for new code; migrate helper-style builders to `mappers/` over time
