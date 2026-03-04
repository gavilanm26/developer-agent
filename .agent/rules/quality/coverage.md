---
trigger: always_on
---

# Coverage Standard

Minimum coverage:

- 95% overall
- 95% on generated/modified module scope (target feature/module)
- Must cover success and failure flows
- No empty spec files allowed
- No real external integrations in unit tests

Execution rule:

- Validate coverage using `npm run test:cov`
- If coverage is below minimum, add or improve tests and rerun in a loop until the threshold passes (when execution is possible)
- Prefer increasing coverage in generated/modified modules first before broad unrelated test changes
- For newly generated modules/features, enforce the same minimum coverage on the generated/modified module scope (not only global coverage)
