# Standard Microservice Module Template

Este template es la guía definitiva (Gold Standard) para crear cualquier nuevo módulo en el proyecto (por ejemplo: `products`, `transactions`, `users`, etc.) que no sea un API Gateway, sino un microservicio normal.

Cuando el usuario pida "crear un nuevo módulo de [nombre]", debes referenciar estrictamente la estructura y convenciones definidas aquí.

## Estructura Esperada (Hexagonal Architecture / DDD)

Todos los módulos deben ser creados dentro de `src/modules/{{module_name}}` y deben seguir exactamente esta jerarquía:

```text
src/modules/{{module_name}}/
├── application/
│   ├── use-cases/
│   │   ├── {{module_name}}.usecase.ts          # Implementación de la lógica de negocio (UseCase)
│   │   └── {{module_name}}.usecase.spec.ts
│   └── ports/
│       └── {{module_name}}.usecase.port.ts     # Puerto de entrada (Inbound Port) que implementa el UseCase
├── domain/
│   ├── models/                                 # OJO: Se usa 'models', NO 'interfaces'
│   │   ├── {{module_name}}-request.model.ts    # Modelos del negocio sin dependencias externas
│   │   └── {{module_name}}-response.model.ts
│   └── ports/
│       ├── {{module_name}}.client.port.ts      # Interfaces que los adapters de infraestructura deben cumplir
│       └── {{module_name}}.cache.port.ts       # Todos los puertos terminan en .port.ts
├── infrastructure/
│   └── adapters/
│       ├── inbound/
│       │   └── http/
│       │       ├── dto/
│       │       │   └── {{module_name}}.request.dto.ts
│       │       ├── {{module_name}}.controller.ts
│       │       └── {{module_name}}.controller.spec.ts
│       └── outbound/
│           ├── clients/
│           │   └── core/
│           │       ├── {{module_name}}.rest.client.ts      # Implementa {{module_name}}.client.port.ts
│           │       └── {{module_name}}.rest.client.spec.ts
│           ├── mappers/
│           │   ├── {{module_name}}.mapper.ts               # Mapea modelos de dominio a DTOs externos
│           │   └── {{module_name}}.mapper.spec.ts
│           └── cache/
│               ├── redis-{{module_name}}.cache.impl.ts     # Implementa {{module_name}}.cache.port.ts
│               └── redis-{{module_name}}.cache.impl.spec.ts
└── {{module_name}}.module.ts
```

## Reglas y Convenciones Estrictas

1. **Uso de UseCases:** La capa de aplicación utiliza `use-cases`, NUNCA `services`. Las clases se llaman `EjemploUseCase` y los archivos terminan en `.usecase.ts`.
2. **Modelos de Dominio:** Los contratos de datos en el dominio van en la carpeta `domain/models/`, terminan en `.model.ts` y las aserciones son Interfaces TypeScript con el sufijo `Model` (ej. `export interface ExampleRequestModel {}`). NO uses la carpeta `interfaces`.
3. **Nomenclatura de Puertos:** Todos los puertos del dominio terminan en `.port.ts` (ej: `foo.client.port.ts`). Si es un cliente HTTP externo, la interfaz de TypeScript debe llamarse `FooClientPort`.
4. **Acoplamiento Nulo en Dominio:** Los archivos en la carpeta `domain` NUNCA pueden importar cosas de `application` o `infrastructure`.
5. **Inyección de Dependencias:** En `{{module_name}}.module.ts`, los proveedores deben mapear la Interfaz (Puerto) hacia la Implementación (Adapter o UseCase) usando tokens, ej: `{ provide: ExampleClientPort, useClass: ExampleRestClient }`.
6. **Mapeo Limpio:** Los Adapters (`rest.client`) nunca construyen headers o transforman bodies directamente; delegan ese trabajo a las clases dentro de `outbound/mappers/`.
7. **Testing Riguroso:** Siempre se deben incluir los archivos `.spec.ts` para cada UseCase, Client, Controller, Mapper y Cache.
8. **Logging e Interceptores:** Todo llamado HTTP saliente debe estar envuelto en el operador `httpLogger()` de `@commons/http-logger/httpLogger`. Todo el módulo debe usar el módulo `httpModuleConfig` de `@commons/https-agent/https.config`.
