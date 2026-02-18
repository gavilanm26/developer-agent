---
trigger: always_on
---

# Hexagonal Binding & Dependency Injection Rule (Ports ↔ Adapters)

## Purpose

This rule defines how **ports must be connected to adapters** inside `feature.module.ts` using dependency injection.
The generator must automatically wire dependencies **only for the technologies actually used by the feature**.

---

# General Binding Pattern

Every domain port must be bound to an infrastructure adapter:

```
providers: [
  UseCase,
  {
    provide: DOMAIN_PORT_TOKEN,
    useClass: InfrastructureAdapter,
  },
]
```

---

# Repository Binding

If the feature uses persistence:

```
{
  provide: USER_REPOSITORY_PORT,
  useClass: MongoUserRepositoryAdapter
}
```

Rules:

* Bind only repositories actually required by use cases
* Do not generate Mongo/SQL/Redis bindings unless requested
* Repository adapters must live in:

  ```
  infrastructure/adapters/outbound/repositories
  ```

---

# External Client Binding

If the feature calls external APIs:

```
{
  provide: PAYMENT_CLIENT_PORT,
  useClass: RestPaymentClientAdapter
}
```

Adapters must live in:

```
infrastructure/adapters/outbound/clients
```

---

# Engine Binding (Rules Engines, Decision Engines)

If the feature uses a rules engine (Zen Engine, Drools, etc.):

```
{
  provide: RULE_ENGINE_PORT,
  useClass: ZenRuleEngineAdapter
}
```

Adapters must live in:

```
infrastructure/adapters/outbound/engines
```

---

# Messaging Binding

If the feature publishes events:

```
{
  provide: USER_EVENT_PUBLISHER_PORT,
  useClass: KafkaUserPublisherAdapter
}
```

Adapters must live in:

```
infrastructure/adapters/outbound/messaging
```

---

# Redis / Cache Binding (Optional)

Only generate when cache is explicitly required:

```
{
  provide: CACHE_REPOSITORY_PORT,
  useClass: RedisCacheRepositoryAdapter
}
```

---

# Injection Token Rule

Ports must define their own injection token:

```
export const USER_REPOSITORY_PORT = 'USER_REPOSITORY_PORT';
```

Never inject adapters directly in use cases.
Always inject the **port token**.

---

# UseCase Injection Pattern

Use cases must depend only on ports:

```
constructor(
  @Inject(USER_REPOSITORY_PORT)
  private readonly repository: UserRepositoryPort,
) {}
```

Never inject infrastructure adapters directly.

---

# Generator Binding Rules

When generating a feature:

1. Detect all domain ports used by the use case.
2. Generate only the adapters required by the feature.
3. Bind each port to its adapter in `feature.module.ts`.
4. Never create bindings for unused technologies.
5. Ensure ports are injected using tokens, not concrete classes.
6. Keep module wiring minimal and aligned with the feature scope.

---

# Reference Wiring Example

```
@Module({
  imports: [],
  controllers: [FeatureController],
  providers: [
    FeatureUseCase,

    {
      provide: FEATURE_REPOSITORY_PORT,
      useClass: MongoFeatureRepositoryAdapter,
    },

    {
      provide: FEATURE_CLIENT_PORT,
      useClass: RestFeatureClientAdapter,
    },
  ],
})
export class FeatureModule {}
```

---

# Final Instruction for Generator

When building a module:

* Always bind **ports → adapters**
* Never inject infrastructure classes into use cases
* Only create bindings required by the feature
* Keep dependency injection explicit and minimal
