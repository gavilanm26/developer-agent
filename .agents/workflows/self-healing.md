---
description: Reglas para la auto-corrección de errores y ejecución autónoma
---

# Self-Healing and Auto-Execution

Este flujo de trabajo define cómo el asistente debe actuar ante errores o tareas de mantenimiento.

## Procedimiento ante Errores

1. **Detección**: Capturar el error de la terminal o de los logs.
2. **Análisis**: Identificar si es un error de sintaxis, falta de dependencia o error de lógica.
3. **Corrección**:
   - Si es falta de dependencia: Instalar con `npm install`.
   - Si es error de TypeScript: Corregir tipos.
   - Si es error de tests: Analizar los resultados de los tests y ajustar la implementación.
4. **Validación**: Re-ejecutar el comando que falló originalmente.

## Ejecución Autónoma
- El asistente puede ejecutar comandos de limpieza (`npm prune`, `git gc`) si detecta problemas de rendimiento o estructura.
- Mantenimiento proactivo de imports y dependencias no utilizadas.
