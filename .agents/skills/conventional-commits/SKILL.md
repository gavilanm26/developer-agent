---
name: conventional-commits
description: Estándar para mensajes de commit siguiendo la especificación Conventional Commits con emojis
---

# Conventional Commits Skill

Esta skill define el estándar para todos los mensajes de commit en el repositorio, asegurando un historial limpio, legible y visualmente claro.

## 1. Estructura General

Cada mensaje de commit debe seguir este formato:

```text
<emoji> <tipo>[alcance opcional]: <descripción>

[cuerpo opcional]

[pie de página opcional]
```

- **Emoji**: Representación visual del tipo de cambio (obligatorio).
- **Tipo**: Describe la intención del cambio (obligatorio).
- **Alcance**: El módulo o área afectada (opcional).
- **Descripción**: Resumen corto en tiempo presente.

---

## 2. Tipos de Commit Comunes

| Tipo | Propósito |
| :--- | :--- |
| **✨ feat** | Una nueva funcionalidad para el usuario. |
| **🐛 fix** | Corrección de un error (bug fix). |
| **📝 docs** | Cambios solo en la documentación. |
| **💄 style** | Cambios que no afectan el significado del código (formato, visual). |
| **♻️ refactor** | Cambio de código que ni corrige un error ni añade funcionalidad. |
| **⚡️ perf** | Cambio de código que mejora el rendimiento. |
| **✅ test** | Añadir o corregir pruebas existentes. |
| **🔧 chore** | Cambios en el proceso de construcción o herramientas auxiliares. |
| **👷 ci** | Cambios en configuración de CI/CD. |

---

## 3. Ejemplos Prácticos

### Commit Simple (Funcionalidad)
`✨ feat(auth): agregar login con Google`

### Commit de Corrección
`🐛 fix(ui): corregir alineación del logo en móviles`

### Commit con Cuerpo y BREAKING CHANGE
```text
✨ feat(api)!: cambiar esquema de respuesta del endpoint de usuarios

BREAKING CHANGE: la propiedad 'user_id' ahora es 'uuid' para cumplir con el estándar.
```

---

## 4. Reglas para el Equipo

1. **Uso de Emojis**: Incluir siempre el emoji correspondiente al inicio del commit.
2. **Minúsculas**: La descripción debe empezar siempre en minúsculas.
3. **Tiempo Presente**: "añadir filtro" en lugar de "añadido filtro".
4. **Unidad Atómica**: Un commit debe representar un solo cambio lógico.

---

## 5. Buenas Prácticas

- **Claridad Visual**: El emoji permite identificar rápidamente el tipo de cambio al revisar el `git log`.
- **Automatización**: Este formato es compatible con herramientas de generación de CHANGELOGs automáticos.
- **Referencia Issues**: Vincula siempre tus tareas (ej: `Fixes #45`).
