# Reglas Maestras: NestJS + Arquitectura Hexagonal

Este documento define la verdad absoluta para la generación de microservicios o features usando NestJS.

## 0. Variables Dinámicas
- `<project_name>`: Nombre del repositorio/proyecto.
- `<service_name>`: Nombre del microservicio (kebab-case).
- `<ServiceName>`: Nombre en PascalCase.

## 1. Estructura de Directorios (NO NEGOCIABLE)
La raíz del feature debe ser: `src/<service_name>/`

| Ruta Relativa | Responsabilidad |
|--------------|-----------------|
| `domain/interfaces/` | DTOs internos del dominio y entidades puras. |
| `domain/ports/` | Contratos (`abstract class`) para Repositorios y Servicios Externos. |
| `application/use-case/` | Lógica de negocio pura (o `application/services`). |
| `application/services/` | Servicios de dominio. |
| `infrastructure/repository/` | **Externo:** Implementación de persistencia (TypeORM, Mongoose). |
| `infrastructure/adapter/` | **Interno:** Implementación de llamadas a otros Microservicios. |
| `infrastructure/controller/` | Entry points (HTTP/REST). |
| `<service_name>.module.ts` | El módulo de NestJS que ensambla todo. |

## 2. Responsabilidades por Capa

### Domain (Puro)
- **Prohibido:** Decoradores de NestJS (excepto `@Injectable` en puertos abstractos).
- **Contenido:** Interfaces, Tipos, Clases de Entidad.

### Application (Orquestación)
- **Inyección:** Usa los puertos abstractos directamente en el constructor.
- **Implementación:** Archivos `*.impl.service.ts`.

### Infrastructure (El mundo real)
- **Repository:** Implementa los puertos de `domain/ports`.
- **Implementación:** Archivos `*.impl.repository.ts`.
- **Controller:** Valida DTOs y llama a Application.

## 3. Convenciones de Código y Patrones

### Inyección de Dependencias (DI)
**REGLA DE ORO:** Usar `abstract class` para los puertos.
- **NO usar interfaces TypeScript** para inyección (evitar Tokens manuales `Symbol`).
- Definición: `export abstract class UserRepositoryPort { ... }`
- Inyección: `constructor(private readonly userRepo: UserRepositoryPort) {}`
- Modulo: `providers: [{ provide: UserRepositoryPort, useClass: UserMongoRepository }]`

### Naming
- Implementaciones: `*.impl.ts` (ej: `user-mongo.impl.repository.ts`).
- Tests: `*.spec.ts` junto al archivo.

## 4. Testing
- Unit tests obligatorios para Services y Controllers.
- Mocks de puertos para aislar capas.

## 5. Checklist de Finalización
1. [ ] ¿Estructura coincide con regla #1?
2. [ ] ¿Puertos son `abstract class`?
3. [ ] ¿Implementaciones terminan en `.impl.ts`?
4. [ ] ¿Tests `.spec.ts` generados?