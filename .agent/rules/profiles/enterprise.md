---
trigger: profile_enterprise_explicit
---

# Enterprise Profile

Activation:
- Apply only when the user explicitly requests the `enterprise` profile.
- Overrides `default` behaviors where conflicts exist.

Overrides default:

- Require injection tokens for ports
- Require explicit inbound contracts
- Enforce CQRS separation (commands/queries)
- Require event publishing for domain changes
- Require stricter logging validation
