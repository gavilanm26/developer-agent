---
trigger: always_on
---

# Dependency Strategy

Default Strategy: Abstract Class Contracts

Example:

export abstract class CreditRepository {
  abstract findById(id: string): Promise<Credit>;
}

Binding:

{
  provide: CreditRepository,
  useClass: MongoCreditRepositoryImpl,
}

Rules:

- UseCases inject abstract contracts only.
- Never inject adapters directly.
- Ports in `application/ports` and `domain/ports` are abstract classes only (no TS interfaces in `ports/*`).
- Concrete implementations must satisfy abstract-class ports using `implements` (not `extends`).
- Controllers inject only the inbound application port (`application/ports/*.usecase.ts`) or an application service bound to that port.
- String tokens allowed only for multi-binding scenarios.
- Module wiring must be explicit and minimal.
- Domain contracts (ports/models/entities/interfaces) must not import application DTOs.
- If an outbound call needs data from an application request DTO, map it in `application/mappers/*` to a domain model before invoking domain ports.
