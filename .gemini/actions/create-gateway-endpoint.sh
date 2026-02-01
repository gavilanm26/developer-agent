#!/usr/bin/env bash
set -euo pipefail

# .gemini/actions/create-gateway-endpoint.sh

ENDPOINT_NAME="${1:-}"
METHOD_NAME="${2:-}"
ROUTE_PATH="${3:-}"
HTTP_METHOD="${4:-Post}"
EXTERNAL_BASE_URL_ENV="${5:-}"
EXTERNAL_PATH="${6:-}"
EXTERNAL_API_VERSION="${7:-/v1}"
GW_MODE="${8:-hybrid}"

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
TPL_DIR="$ROOT_AGENT_DIR/.gemini/.templates/templates-gateway-endpoint"

# El comando se asume que se corre en la raíz del proyecto Nest
SRC_DIR="src"
ENDPOINT_DIR="$SRC_DIR/endpoint/$ENDPOINT_NAME"

mkdir -p "$ENDPOINT_DIR"

# --- FLUJO DE CREACIÓN ---
if [[ -d "$TPL_DIR/$ENDPOINT_NAME" ]]; then
  echo "📂 Detectada carpeta de template específica para '$ENDPOINT_NAME'. Copiando..."
  cp -r "$TPL_DIR/$ENDPOINT_NAME/"* "$ENDPOINT_DIR/"
  
  # Quitar extensión .tpl recursivamente
  find "$ENDPOINT_DIR" -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
  
  # Limpieza de GraphQL si estamos en modo REST
  if [ "$GW_MODE" == "rest" ]; then
      echo "🧹 Limpiando GraphQL de los archivos de '$ENDPOINT_NAME'..."
      find "$ENDPOINT_DIR" -name "*.ts" -exec sh -c 'source "'"$ROOT_AGENT_DIR"'/.gemini/core/utils.sh"; clean_graphql_artifacts "$1"' _ {} \;
  fi
  
  echo "✅ Estructura copiada fielmente desde el template."
fi

# Registrar en app.module.ts usando el sincronizador universal
echo "🔗 Sincronizando módulos con AppModule..."
bash "$ROOT_AGENT_DIR/.gemini/core/sync-appmodule-endpoints.sh" || echo "⚠️ Error al sincronizar módulos."

echo "✅ Endpoint gateway creado en: src/endpoint/$ENDPOINT_NAME"