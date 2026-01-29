#!/bin/bash
set -euo pipefail

# .gemini/core/sync-appmodule-endpoints.sh
# Sincronizador Estable para NestJS

APP_MODULE="src/app.module.ts"
ENDPOINT_DIR="src/endpoint"
ANCHOR="// <<ENDPOINT_IMPORTS>>"

if [[ ! -f "$APP_MODULE" ]]; then
  exit 0
fi

# Detectar módulos ignorando carpetas de basura
MODULE_FILES=$(find "$ENDPOINT_DIR" -type f -name "*.module.ts" -not -path "*/coverage/*" -not -path "*/dist/*" | sort)

while IFS= read -r f; do
  [ -z "$f" ] && continue
  
  class_name=$(grep -Eo "export[[:space:]]+class[[:space:]]+[A-Za-z0-9_]+" "$f" | awk '{print $3}')
  rel="${f#src/}"
  import_path="./${rel%.ts}"
  
  if [[ ! -z "$class_name" ]]; then
    # 1. Asegurar Import
    if ! grep -q "import { $class_name }" "$APP_MODULE"; then
      sed -i '' "1i\\
import { $class_name } from '$import_path';" "$APP_MODULE"
    fi
    
    # 2. Asegurar Registro en array
    if ! grep -q "$class_name," "$APP_MODULE"; then
      sed -i '' "s|$ANCHOR|$class_name,\\
    $ANCHOR|" "$APP_MODULE"
    fi
  fi
done <<< "$MODULE_FILES"

# Reparación de emergencia para el decorador dañado
sed -i '' "s/@.*(/@Module(/g" "$APP_MODULE" 2>/dev/null

echo "✅ Sincronización completada."
