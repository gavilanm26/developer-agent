# Reglas para Crear Módulos/Features (NestJS Hexagonal)

Estas reglas aplican al comando `create-module` cuando se trabaja en un proyecto NestJS.

## 1. Definición de Puertos (CRÍTICO)
- **Tipo:** Los puertos en `domain/ports` DEBEN ser `abstract class`.
- **Decorador:** Deben llevar `@Injectable()`.
- **Prohibido:** No usar `interface` para puertos (para aprovechar la DI de NestJS sin tokens manuales).

## 2. Ubicación y Naming
- Ruta: `src/<module_name>/`
- Formato: `kebab-case` para carpetas y archivos.
- Clases: `PascalCase`.

## 3. Estructura Interna del Módulo
Dentro de `src/<module_name>/`:

| Carpeta | Contenido |
|---------|-----------|
| `application/service/` | Lógica de orquestación (Use Cases). |
| `domain/interfaces/` | DTOs de dominio, entidades anémicas. |
| `domain/ports/` | Contratos (`abstract class`) con el mundo exterior. |
| `infrastructure/controller/` | Controladores HTTP/Eventos. |
| `infrastructure/repository/` | **Integraciones EXTERNAS** (DB, APIs Terceros, Cloud). |
| `infrastructure/adapter/` | **Integraciones INTERNAS** (Otros microservicios propios). |
| `infrastructure/repository/helpers/` | Mappers, utilidades de query, etc. |
| `infrastructure/dto/` | DTOs de entrada/salida (Request/Response). |

## 4. Implementación y Sufijos
- **Servicios de Aplicación:** `application/service/<module>.impl.service.ts`
  - *Regla:* Solo habla con `domain/ports`, nunca con infraestructura directa.
- **Repositorios:** `infrastructure/repository/<module>.impl.repository.ts`
- **Adaptadores:** `infrastructure/adapter/<target>.impl.adapter.ts`
- **Module:** `src/<module_name>/<module_name>.module.ts`

## 5. Repository vs Adapter
- **Repository:** Si vas a MongoDB, Redis, S3, o API de un tercero (ej: Stripe).
- **Adapter:** Si vas a llamar a `orders-microservice` (interno) vía HTTP/gRPC.

## 6. Controller
- Solo valida entrada (DTOs con `class-validator`) y llama al servicio de aplicación.
- No contiene lógica de negocio.

## 7. Testing (Obligatorio)
Generar archivo `.spec.ts` adyacente a la implementación.
- 1 spec para `impl.service` (Unitario).
- 1 spec para `impl.repository` / `adapter`.
- Cobertura mínima: Camino feliz + 1 caso de error.

## 8. Definition of Done
1. [ ] Estructura de carpetas creada correctamente.
2. [ ] Puertos definidos como `abstract class`.
3. [ ] Archivos de implementación con sufijo `.impl.ts`.
4. [ ] Módulo creado y providers registrados.
5. [ ] Tests unitarios generados.
