# AGENTS.md

Bootstrap instructions for any AI coding agent (Codex, GPT, Gemini, etc.) working in this repository.

## Mandatory Startup

Before performing analysis, scaffolding, refactor, or code generation:

1. Read `.agent/AGENTS.md`
2. Load rules in the order defined there
3. Apply `rules/profiles/default.md` unless the user explicitly requests another profile (`enterprise` or `cqrs`)
4. Follow `.agent/tools/execution-policies.md`

## Source of Truth

The `.agent/` directory is the repository policy package and is the source of truth for:

- architecture rules
- scaffolding rules
- quality rules
- conventions
- profiles
- templates used for scaffolding/bootstrap
- execution policies
- architectural decisions memory

If a task conflicts with `.agent` rules, ask for clarification or document an approved exception in:

- `.agent/memory/architectural-decisions.md`
