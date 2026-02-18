# Estándares de Código del Agente

Estas reglas deben aplicarse a TODO el código generado por las acciones `create-microservice` y `create-module`.

## 1. General (Node.js)
- **Modularidad:** Usar ES Modules (`import`/`export`) en lugar de CommonJS (`require`), a menos que se especifique lo contrario.
- **Asincronía:** Preferir siempre `async/await` sobre Promesas encadenadas `.then()`.
- **Variables:** Usar `const` por defecto, `let` solo si es necesario. NUNCA usar `var`.

## 2. Estructura de Microservicios
- **Separation of Concerns:**
  - `controllers/`: Manejan la petición HTTP y respuesta.
  - `services/`: Contienen la lógica de negocio pura.
  - `routes/`: Definiciones de endpoints.
- **Manejo de Errores:** Todos los endpoints deben estar envueltos en bloques `try/catch` o usar un middleware de manejo de errores global.

## 3. Naming Conventions
- Archivos: `kebab-case.js` (ej: `user-controller.js`)
- Clases: `PascalCase` (ej: `UserController`)
- Funciones/Variables: `camelCase` (ej: `getUserById`)
