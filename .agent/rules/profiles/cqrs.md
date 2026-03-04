---
trigger: profile_cqrs_explicit
---

# CQRS Profile

Activation:
- Apply only when the user explicitly requests the `cqrs` profile.
- Can be combined with `enterprise` only if explicitly requested.

- Separate commands and queries folders
- Commands modify state
- Queries read state
- Enforce clear segregation in application layer
- Domain logic shared where applicable
