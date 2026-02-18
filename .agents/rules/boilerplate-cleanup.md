# Regla: Limpieza de Boilerplate NestJS

Al inicializar un nuevo microservicio, es OBLIGATORIO eliminar los archivos por defecto que genera el Nest CLI para mantener la arquitectura hexagonal pura desde el inicio.

## Archivos a eliminar:
- `src/app.controller.ts`
- `src/app.service.ts`
- `src/app.controller.spec.ts`

## Ajuste de `app.module.ts`:
El `AppModule` debe quedar vacío de controladores y proveedores iniciales, sirviendo únicamente como el punto de entrada para importar los módulos de los features/microservicios.

```typescript
import { Module } from '@nestjs/common';

@Module({
  imports: [],
  controllers: [],
  providers: [],
})
export class AppModule {}
```
