#!/usr/bin/env bash
set -euo pipefail

# Usage:
# ./actions/create-gateway-endpoint.sh <endpoint-name> <method-name> <route> <httpMethod> <EXTERNAL_BASE_URL_ENV> <EXTERNAL_PATH> [EXTERNAL_API_VERSION]

ENDPOINT_NAME="${1:-}"
METHOD_NAME="${2:-}"
ROUTE_PATH="${3:-}"
HTTP_METHOD="${4:-Post}"
EXTERNAL_BASE_URL_ENV="${5:-}"
EXTERNAL_PATH="${6:-}"
EXTERNAL_API_VERSION="${7:-/v1}"

if [[ -z "$ENDPOINT_NAME" || -z "$METHOD_NAME" ]]; then
  echo "❌ Uso: create-gateway-endpoint.sh <endpoint-name> <method-name> <route> <httpMethod> <EXTERNAL_BASE_URL_ENV> <EXTERNAL_PATH> [EXTERNAL_API_VERSION]"
  exit 1
fi

to_pascal() {
  echo "$1" | awk -F'-' '{ for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } }1' OFS=''
}

# Obtener ruta absoluta de la carpeta del agente
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_AGENT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TPL_DIR="$ROOT_AGENT_DIR/.gemini/actions/templates-gateway-endpoint"

# El comando se asume que se corre en la raíz del proyecto Nest
SRC_DIR="src"
ENDPOINT_DIR="$SRC_DIR/endpoint/$ENDPOINT_NAME"

ENDPOINT_PASCAL="$(to_pascal "$ENDPOINT_NAME")"
MODULE_CLASS="${ENDPOINT_PASCAL}Module"

mkdir -p \
  "$ENDPOINT_DIR/application" \
  "$ENDPOINT_DIR/domain/interfaces" \
  "$ENDPOINT_DIR/infrastructure/controller" \
  "$ENDPOINT_DIR/infrastructure/dto" \
  "$ENDPOINT_DIR/infrastructure/adapter"

# --- NUEVO: Copiar archivos estáticos y tests pre-definidos si existen ---
if [[ -d "$TPL_DIR/$ENDPOINT_NAME" ]]; then
  echo "📂 Copiando estructura y tests pre-definidos para '$ENDPOINT_NAME'..."
  # Copiamos todo el contenido de la carpeta template (application, domain, infrastructure, etc)
  cp -r "$TPL_DIR/$ENDPOINT_NAME/"* "$ENDPOINT_DIR/"
fi
# -----------------------------------------------------------------------

render_tpl() {
  local tpl="$1"
  local out="$2"

  if [[ ! -f "$tpl" ]]; then
    echo "❌ Template no existe: $tpl"
    exit 1
  fi

  sed \
    -e "s/{{ENDPOINT_NAME}}/$ENDPOINT_NAME/g" \
    -e "s/{{ENDPOINT_PASCAL}}/$ENDPOINT_PASCAL/g" \
    -e "s/{{MODULE_CLASS}}/$MODULE_CLASS/g" \
    -e "s/{{METHOD_NAME}}/$METHOD_NAME/g" \
    -e "s#{{ROUTE_PATH}}#$ROUTE_PATH#g" \
    -e "s/{{HTTP_METHOD}}/$HTTP_METHOD/g" \
    -e "s/{{EXTERNAL_BASE_URL_ENV}}/$EXTERNAL_BASE_URL_ENV/g" \
    -e "s#{{EXTERNAL_PATH}}#$EXTERNAL_PATH#g" \
    -e "s#{{EXTERNAL_API_VERSION}}#$EXTERNAL_API_VERSION#g" \
    "$tpl" > "$out"
}

echo "📦 Renderizando plantillas para el endpoint '$ENDPOINT_NAME'ப்பான"
render_tpl "$TPL_DIR/endpoint.module.ts.tpl" "$ENDPOINT_DIR/$ENDPOINT_NAME.module.ts"
render_tpl "$TPL_DIR/endpoint.controller.ts.tpl" "$ENDPOINT_DIR/infrastructure/controller/$ENDPOINT_NAME.controller.ts"
render_tpl "$TPL_DIR/domain.service.ts.tpl" "$ENDPOINT_DIR/domain/$ENDPOINT_NAME.service.ts"
render_tpl "$TPL_DIR/domain.adapter.ts.tpl" "$ENDPOINT_DIR/domain/$ENDPOINT_NAME.adapter.ts"
render_tpl "$TPL_DIR/impl.service.ts.tpl" "$ENDPOINT_DIR/application/$ENDPOINT_NAME.impl.service.ts"
render_tpl "$TPL_DIR/ms.adapter.ts.tpl" "$ENDPOINT_DIR/infrastructure/adapter/ms-$ENDPOINT_NAME.adapter.ts"
render_tpl "$TPL_DIR/dto.ts.tpl" "$ENDPOINT_DIR/infrastructure/dto/$ENDPOINT_NAME.dto.ts"
render_tpl "$TPL_DIR/request.interface.ts.tpl" "$ENDPOINT_DIR/domain/interfaces/$ENDPOINT_NAME-request.interface.ts"
render_tpl "$TPL_DIR/response.interface.ts.tpl" "$ENDPOINT_DIR/domain/interfaces/$ENDPOINT_NAME-response.interface.ts"

# Registrar en app.module.ts
APP_MODULE="$SRC_DIR/app.module.ts"
IMPORT_LINE="import { ${MODULE_CLASS} } from './endpoint/${ENDPOINT_NAME}/${ENDPOINT_NAME}.module';"

if [[ -f "$APP_MODULE" ]]; then
  if ! grep -qF "$IMPORT_LINE" "$APP_MODULE"; then
    # inserta import antes del bloque de @Module
    sed -i '' "/@Module/i\\
$IMPORT_LINE
" "$APP_MODULE" || echo "⚠️ No pude insertar import automáticamente."
  fi

  # agrega el módulo dentro del array imports
  if ! grep -q "\b${MODULE_CLASS}\b" "$APP_MODULE"; then
    sed -i '' "s/imports: [/
    imports: [
    ${MODULE_CLASS},"/ "$APP_MODULE" || echo "⚠️ No pude insertar en imports."
  fi
fi

echo "✅ Endpoint gateway creado en: src/endpoint/$ENDPOINT_NAME"
