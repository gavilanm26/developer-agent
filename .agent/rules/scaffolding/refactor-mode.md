---
trigger: always_on
---

# Refactor Mode

When refactoring:

1. Detect architectural violations.
2. Move inbound contracts to application.
3. Move outbound contracts to domain.
4. Remove business logic from controllers.
5. Move logging to outbound adapters only.
6. Remove unused technologies.
7. Preserve behavior.
8. Generate missing tests.

Refactor must not change functional behavior.