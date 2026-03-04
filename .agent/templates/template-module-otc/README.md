# OTC Module Template

Template oficial para generar el módulo `otc` con estructura completa y dos submódulos:

- `otc/generate`
- `otc/validate`

## Uso esperado

Cuando se solicite crear el módulo `otc`, se debe scaffoldar este template completo (no por partes), manteniendo:

- `otc/otc.module.ts`
- `generate` y `validate` como módulos separados
- contratos de dominio en `domain/models` y `domain/ports`
- mapeo en `application/mappers`
- adapters inbound/outbound en `infrastructure/adapters`

## Reglas importantes

- `domain` no importa `application` ni `infrastructure`.
- `application` reutiliza `BasicDataRequestModel` como request base.
- Payload enriquecido a integraciones externas va en modelos `*payload.model.ts`.
- Clientes `core` van en `outbound/clients/core`.
- Clientes de commons compartidos van en `outbound/clients/commons`.
