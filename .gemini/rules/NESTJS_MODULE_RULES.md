# Reglas: NestJS Gateway Endpoints

## Estructura Obligatoria (Hexagonal-ish)
- Cada endpoint vive en: `src/endpoint/<endpoint-name>` (kebab-case).
- Debe existir `<endpoint-name>.module.ts`.
- Debe existir controller en: `infrastructure/controller`.
- Debe existir service abstract class en: `domain/<endpoint-name>.service.ts`.
- Debe existir adapter abstract class en: `domain/<endpoint-name>.adapter.ts`.
- `application` contiene el `ImplService` (orquestación).
- `infrastructure/adapter` contiene `Ms<Endpoint>Adapter` (consumo a microservicios externos).

## Puertos y Tipado
- Los puertos (Service/Adapter) **SIEMPRE** son `abstract class` con el decorador `@Injectable()`. No usar interfaces.
- Las implementaciones se inyectan en el módulo usando el patrón `{ provide: Service, useClass: Impl }`.
