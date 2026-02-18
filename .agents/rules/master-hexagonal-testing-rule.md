---
trigger: always_on
---

# Master Hexagonal Testing Rule (Automatic Test Generation)

## Purpose

Garantizar que **todo artefacto generado en arquitectura hexagonal incluya automáticamente su archivo de pruebas unitarias**, manteniendo cobertura estructural desde el momento de creación del módulo.

---

# Mandatory Test Coverage Rule

Cada archivo funcional generado debe crear automáticamente su archivo `.spec.ts` correspondiente.

## File Mapping Rules

| Archivo generado       | Test obligatorio            |
| ---------------------- | --------------------------- |
| `*.usecase.ts`         | `*.usecase.spec.ts`         |
| `*.service.ts`         | `*.service.spec.ts`         |
| `*.repository.impl.ts` | `*.repository.impl.spec.ts` |
| `*.adapter.ts`         | `*.adapter.spec.ts`         |
| `*.controller.ts`      | `*.controller.spec.ts`      |
| `*.engine.adapter.ts`  | `*.engine.adapter.spec.ts`  |
| `*.client.ts`          | `*.client.spec.ts`          |

Ningún archivo funcional puede generarse sin su test asociado.

---

# Test Construction Rules

## UseCases

Los tests deben:

* Mockear todos los **ports**
* Probar:

  * flujo exitoso
  * errores controlados
  * condiciones de negocio
* No usar infraestructura real

---

## Adapters / Repositories

Los tests deben:

* Mockear dependencias externas (HttpService, Model, Redis, etc.)
* Validar:

  * request generado
  * response mapping
  * manejo de errores

---

## Controllers

Los tests deben:

* Mockear el UseCase
* Validar:

  * status codes
  * response mapping
  * validaciones de entrada

---

# Coverage Rules

Los tests generados deben cubrir:

* Happy path
* Error path
* Null / not-found cases
* Validation failures

---

# Generation Enforcement Rule

El generador debe:

1. Crear automáticamente el `.spec.ts` junto con cada archivo funcional
2. Incluir mocks iniciales listos
3. Mantener strict typing
4. Garantizar estructura AAA (Arrange / Act / Assert)
5. No generar tests vacíos

---

# Example

Generar:

```
evaluate-rule.usecase.ts
evaluate-rule.usecase.spec.ts

mongo-validation-rule.repository.impl.ts
mongo-validation-rule.repository.impl.spec.ts

rules.controller.ts
rules.controller.spec.ts
```

---

# Final Instruction for Generator

Cuando se genere cualquier módulo o feature:

* Crear automáticamente los tests de todos los componentes
* Mockear puertos en UseCases
* Mockear infraestructura en Adapters
* Garantizar cobertura inicial estructural completa
* No permitir generación de archivos funcionales sin tests asociados
