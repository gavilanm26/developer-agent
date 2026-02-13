---
trigger: always_on
---

# Unit Test Generation Rule

## Mandatory Test Generation

Cada archivo de la arquitectura debe generar su archivo de pruebas asociado automáticamente.

### Reglas

1. Todo **UseCase** debe tener:

   ```
   *.usecase.ts
   *.usecase.spec.ts
   ```

2. Todo **Adapter** debe tener:

   ```
   *.adapter.ts
   *.adapter.spec.ts
   ```

3. Todo **Repository Implementation** debe tener:

   ```
   *.repository.impl.ts
   *.repository.impl.spec.ts
   ```

4. Todo **Controller** debe tener:

   ```
   *.controller.ts
   *.controller.spec.ts
   ```

5. Los tests deben:

   * Usar mocks de ports
   * Cubrir casos éxito y error
   * Mantener strict typing
   * No depender de infraestructura real

6. Ningún archivo funcional puede generarse sin su `.spec.ts` correspondiente.
