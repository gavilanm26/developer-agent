#!/bin/bash
set -euo pipefail

# .gemini/core/sync-appmodule-endpoints.sh
# Sincronizador de Alta Precisión con Escapado de Caracteres Especiales

APP_MODULE="src/app.module.ts"
ENDPOINT_DIR="src/endpoint"
ANCHOR="// <<ENDPOINT_IMPORTS>>"

if [[ ! -f "$APP_MODULE" ]]; then
  exit 0
fi

# 1. Asegurar ancla (Usando comillas simples y escape para evitar que Perl se confunda)
if ! grep -q "<<ENDPOINT_IMPORTS>>" "$APP_MODULE"; then
    perl -i -pe 's/imports: \[ /imports: [\n    \/\/ <<ENDPOINT_IMPORTS>>/' "$APP_MODULE"
fi

# 2. Procesar módulos
MODULE_FILES=$(find "$ENDPOINT_DIR" -maxdepth 4 -name "*.module.ts" | grep -v "coverage" | grep -v "dist" | sort)

while IFS= read -r f; do
  [ -z "$f" ] && continue
  
  # Extraer nombre real de la clase
  class_name=$(grep -m 1 -Eo "export[[:space:]]+class[[:space:]]+[A-Za-z0-9_]+" "$f" | awk '{print $3}')
  [ -z "$class_name" ] && continue

  rel="${f#src/}"
  import_path="./${rel%.ts}"
  
  # A. Asegurar Import (Sin duplicados)
  if ! grep -q "from '$import_path'" "$APP_MODULE"; then
      perl -i -pe "print \"import { $class_name } from '$import_path';\n\" if $. == 1" "$APP_MODULE"
  fi
  
  # B. Asegurar Registro en array
  if ! grep -qE "([[:space:]]|^)$class_name(,|])" "$APP_MODULE"; then
    # Usamos una variable intermedia para evitar problemas con << en la regex de Perl
    perl -i -pe "s|// <<ENDPOINT_IMPORTS>>|$class_name,\n    // <<ENDPOINT_IMPORTS>>|" "$APP_MODULE"
  fi
done <<< "$MODULE_FILES"

# 3. Limpieza final de seguridad
perl -i -pe 's/^\s*\@src.*Module\(/@Module(/g' "$APP_MODULE"
perl -i -pe 's/^.*\@Module/\@Module/g' "$APP_MODULE"

echo "✅ Sincronización completada."