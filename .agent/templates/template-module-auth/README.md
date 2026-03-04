# Auth Module Templates

This folder provides two explicit auth module variants:

- `with-re-captcha/`
- `without-re-captcha/`

## Selection Rules

- Use `with-re-captcha` only when auth flow explicitly requires reCAPTCHA verification.
- Use `without-re-captcha` when auth flow does not require reCAPTCHA.
- `without-re-captcha` must not import/use any `re-captcha` module/port/DTO field.

## Shared Conventions

- `documentType` uses `TypeOfDocuments` from `@commons/enums/type-of-documents.enum`.
- Auth templates rely on `commons/libs/crypto/crypto-core` for encryption in outbound mappers.
- `commons/libs/crypto` should be scaffolded only when generating/refactoring auth modules.
- Token core dependency must come from shared commons (`commons/token/*`) without creating extra hexagonal token folders.
- Use `TokenModule` from `commons/token/token.module` and `TokenAdapter` from `commons/token/adapter/token.adapter`.
- Outbound core auth clients follow official structure under `infrastructure/adapters/outbound/clients/core/*`.
- `CoreAuthRestClient` consumes token payload via `(await tokenCore.get()).data` and passes request context to mapper headers.

## Notes

- Templates are module-scoped references (auth domain/application/infrastructure).
- Keep outbound URL/header/request assembly in outbound mappers (`set-data.mapper`).
