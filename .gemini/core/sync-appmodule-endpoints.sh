#!/bin/bash
set -euo pipefail

# .gemini/core/sync-appmodule-endpoints.sh
# Sincronizador Idempotente para NestJS

APP_MODULE="src/app.module.ts"
ENDPOINT_DIR="src/endpoint"
ANCHOR="// <<ENDPOINT_IMPORTS>>"

if [[ ! -f "$APP_MODULE" ]]; then
  exit 0
fi

# 1. Asegurar que el ancla existe si el archivo está vacío o dañado
if ! grep -q "$ANCHOR" "$APP_MODULE"; then
    # Si no hay ancla, intentamos ponerla en el array de imports
    sed -i '' "s/imports: [/imports: [\n    $ANCHOR/" "$APP_MODULE" 2>/dev/null || \
    sed -i "s/imports: [/imports: [\n    $ANCHOR/" "$APP_MODULE"
fi

# 2. Detectar módulos (Filtro estricto: solo archivos .ts reales, ignorando basura)
# Usamos -maxdepth para no entrar en carpetas de reportes o tests si no es necesario
MODULE_FILES=$(find "$ENDPOINT_DIR" -maxdepth 4 -name "*.module.ts" | grep -v "coverage" | grep -v "dist" | sort)

while IFS= read -r f; do
  [ -z "$f" ] && continue
  
  # Extraer nombre de la clase (ej: AuthModule)
  class_name=$(grep -Eo "export[[:space:]]+class[[:space:]]+[A-Za-z0-9_]+" "$f" | awk '{print $3}')
  [ -z "$class_name" ] && continue

  # Construir path relativo limpio
  rel="${f#src/}"
  import_path="./${rel%.ts}"
  
  # A. Asegurar Import en la parte superior (Sin duplicados)
  if ! grep -q "import { $class_name } from" "$APP_MODULE"; then
    # Insertar al inicio del archivo
    sed -i '' "1i\\
import { $class_name } from '$import_path';" "$APP_MODULE" 2>/dev/null || \
    sed -i "1iimport { $class_name } from '$import_path';" "$APP_MODULE"
  fi
  
  # B. Asegurar Registro en el array de imports (Idempotente)
  # Buscamos la clase seguida de coma o cierre de array
  if ! grep -qE "([[:space:]]|^)$class_name(,|])" "$APP_MODULE"; then
    echo "Agregando $class_name al array de imports..."
    sed -i '' "s|$ANCHOR|$class_name,\
    $ANCHOR|" "$APP_MODULE" 2>/dev/null || \
    sed -i "s|$ANCHOR|$class_name,\
    $ANCHOR|" "$APP_MODULE"
  fi
done <<< "$MODULE_FILES"

# 3. Limpieza final de seguridad
# Eliminar posibles duplicados de la misma línea de import (por si acaso)
# Y restaurar el decorador @Module si algo lo corrompió
perl -i -pe 'BEGIN{undef $/;} s/(@Module\s*\{\s*imports:\s*\[)\s*($class_name,\s*)+/$1/g' "$APP_MODULE" 2>/dev/null || true

# Reparación definitiva del decorador (Elimina basura antes del @Module)
sed -i '' "s|^.*@Module|@Module|g" "$APP_MODULE" 2>/dev/null || \
sed -i "s|^.*@Module|@Module|g" "$APP_MODULE"

echo "✅ Sincronización completada."