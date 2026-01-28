# Reglas: NestJS Gateway Service

## Responsabilidades
- El Gateway actúa como proxy y orquestador.
- No contiene lógica de negocio pesada, solo mapeo de peticiones y validaciones.

## Configuración Base (Bootstrap)
- Debe cargar `dotenv`.
- Debe usar `ValidationPipe` global.
- Debe configurar CORS.
- Debe tener `app.module.ts` preparado para inyección dinámica de módulos de endpoint.

## Estructura de Carpetas
- `src/endpoint/`: Contiene todos los módulos que exponen rutas hacia microservicios externos.
- `src/commons/`: Interceptores, Filtros de Excepciones, Loggers compartidos.
