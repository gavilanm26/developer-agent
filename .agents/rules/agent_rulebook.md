# AGENT RULEBOOK: Universal Hexagonal Standards

## 1. The Prime Directive
You are the **Developer Agent**. You do not just "run scripts"; you **embody** the architecture defined in this repository. 
**Source of Truth:** `.agents/rules/master-hexagonal-ruleset.md`

## 2. Universal Layering (Strict Enforcement)
Every feature or microservice MUST follow this structure. No exceptions.

```
src/
 ├── application/      # ORCHESTRATION (UseCases, DTOs)
 ├── domain/           # BUSINESS LOGIC (Entities, Ports)
 ├── infrastructure/   # IMPLEMENTATION (Adapters, Controllers, Repositories)
 └── *.module.ts       # WIRING
```

### 🚫 Forbidden Actions
- **NEVER** import `infrastructure` into `domain` or `application`.
- **NEVER** use framework decorators (e.g., `@Controller`, `@Injectable`) in `domain`.
- **NEVER** define DTOs inline. ALWAYS use dedicated files in `application/dto` or `infrastructure/dto`.
- **NEVER** skip testing. Every `.ts` file must have a `.spec.ts`.

## 3. Naming Conventions (Non-Negotiable)

| Type | Suffix | Location | Example |
| :--- | :--- | :--- | :--- |
| **Port** | `.port.ts` | `domain/ports` | `user.repository.port.ts` |
| **Entity** | `.entity.ts` | `domain/entities` | `user.entity.ts` |
| **Adapter (Repo)** | `.repository.impl.ts` | `infrastructure/adapters/outbound/repositories` | `mongo-user.repository.impl.ts` |
| **Adapter (Ext)** | `.client.ts` | `infrastructure/adapters/outbound/clients` | `stripe.client.ts` |
| **Controller** | `.controller.ts` | `infrastructure/adapters/inbound/http` | `user.controller.ts` |
| **UseCase** | `.usecase.ts` | `application/use-cases` | `create-user.usecase.ts` |
| **DTO (App)** | `.input.dto.ts` | `application/dto` | `create-user.input.dto.ts` |
| **DTO (HTTP)** | `.http.dto.ts` | `infrastructure.../dto` | `create-user.http.dto.ts` |

## 4. Implementation Protocol

### When "Creating a Microservice"
1.  **Context**: You represent the specific "User Mode".
2.  **Action**: Use the efficient verified path (`.agents/actions/create-service-nestjs.sh`) BUT ensure you verify the result against these rules.
3.  **Mindset**: You are not "running a command"; you are **generating the standard**.

### When "Writing Manual Code"
1.  **Define Ports First**: Start in `domain/ports`. Define the interface `UserRepositoryPort`.
2.  **Define UseCase**: Create `application/use-cases/register-user.usecase.ts`. Inject `USER_REPOSITORY_PORT`.
3.  **Implement Adapter**: Create `infrastructure/.../mongo-user.repository.impl.ts`. Implement the port.
4.  **Wire Module**: In `user.module.ts`, bind: `{ provide: USER_REPOSITORY_PORT, useClass: MongoUserRepositoryAdapter }`.

## 5. Validating "My Way"
If the User says "Create it my way", check:
- Is `application` free of database calls?
- Are `ports` defined as interfaces with const tokens?
- Does every controller validate input with `class-validator` DTOs?
