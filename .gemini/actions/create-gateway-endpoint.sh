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

ENDPOINT_PASCAL="$(to_pascal "$ENDPOINT_NAME")"
MODULE_CLASS="${ENDPOINT_PASCAL}Module"

mkdir -p "$ENDPOINT_DIR"

# --- FLUJO DE CREACIÓN ---
SKIP_TPL=false
if [[ -d "$TPL_DIR/$ENDPOINT_NAME" ]]; then
  echo "📂 Detectada carpeta de template específica para '$ENDPOINT_NAME'. Copiando..."
  # Copiamos la carpeta completa al destino
  cp -r "$TPL_DIR/$ENDPOINT_NAME/"* "$ENDPOINT_DIR/"
  echo "✅ Estructura copiada fielmente desde el template."
  SKIP_TPL=true
fi

# Si no hay template de carpeta, usar los archivos .tpl individuales (opcional)
# Por ahora priorizamos tus carpetas.

# Registrar en app.module.ts usando el sincronizador universal
echo "🔗 Sincronizando módulos con AppModule..."
bash "$ROOT_AGENT_DIR/.gemini/core/sync-appmodule-endpoints.sh" || echo "⚠️ Error al sincronizar módulos."

echo "✅ Endpoint gateway creado en: src/endpoint/$ENDPOINT_NAME"