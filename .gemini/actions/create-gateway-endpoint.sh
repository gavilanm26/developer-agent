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

if [[ -z "$ENDPOINT_NAME" ]]; then
  echo "❌ Uso: ./dev-agent.sh new-endpoint <nombre-modulo>"
  exit 1
fi

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

to_pascal() {
  echo "$1" | awk -F'-' '{ for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } }1' OFS=''
}

# Rutas absolutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_AGENT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TPL_DIR="$ROOT_AGENT_DIR/.gemini/.templates/templates-gateway-endpoint"
ENDPOINT_DIR="src/endpoint/$ENDPOINT_NAME"

# IMPORTANTE: Importar utilidades
if [ -f "$ROOT_AGENT_DIR/.gemini/core/utils.sh" ]; then
    source "$ROOT_AGENT_DIR/.gemini/core/utils.sh"
fi

# Asegurar que la carpeta TMP del agente exista
mkdir -p "$ROOT_AGENT_DIR/.gemini/tmp"

echo -e "${BLUE}🔨 Creando módulo NestJS '$ENDPOINT_NAME'...${NC}"

# 1. Nest CLI
if [ ! -d "$ENDPOINT_DIR" ]; then
    npx nest g mo "endpoint/$ENDPOINT_NAME" --no-spec >/dev/null
fi

mkdir -p "$ENDPOINT_DIR"/{application/service,domain/{interfaces,ports},infrastructure/{controller,adapter,dto}}

# 2. Lógica de Templates
if [[ -d "$TPL_DIR/$ENDPOINT_NAME" ]]; then
    echo -e "${GREEN}📂 Usando template específico para '$ENDPOINT_NAME'.${NC}"
    cp -r "$TPL_DIR/$ENDPOINT_NAME/"* "$ENDPOINT_DIR/"
    find "$ENDPOINT_DIR" -path "*/.gemini" -prune -o -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
else
    echo -e "${YELLOW}🤖 Generando código inteligente para '$ENDPOINT_NAME'...${NC}"
    FILES=(
        "endpoint.controller.ts.tpl:infrastructure/controller/${ENDPOINT_NAME}.controller.ts"
        "impl.service.ts.tpl:application/service/${ENDPOINT_NAME}.impl.service.ts"
        "domain.adapter.ts.tpl:domain/ports/${ENDPOINT_NAME}.adapter.ts"
        "ms.adapter.ts.tpl:infrastructure/adapter/ms-${ENDPOINT_NAME}.impl.adapter.ts"
        "dto.ts.tpl:infrastructure/dto/${ENDPOINT_NAME}.dto.ts"
    )
    for entry in "${FILES[@]}"; do
        TPL_FILE="${entry%%:*}"; TARGET_FILE="${entry#*:}"
        if [ -f "$TPL_DIR/$TPL_FILE" ]; then
            PROMPT="ERES UN ARQUITECTO NESTJS. Transforma este template GENERICO al módulo '$ENDPOINT_NAME'.
            Reglas: 1. Cambia 'Endpoint' a '$(to_pascal "$ENDPOINT_NAME")'. 2. Usa @commons, @dto. 3. Metodo: ${METHOD_NAME:-default}.
            TEMPLATE: $(cat "$TPL_DIR/$TPL_FILE")"
            mkdir -p "$(dirname "$ENDPOINT_DIR/$TARGET_FILE")"
            
            # Usar ruta ABSOLUTA para el prompt
            PROMPT_TMP="$ROOT_AGENT_DIR/.gemini/tmp/prompt_gen.txt"
            echo "$PROMPT" > "$PROMPT_TMP"
            bash "$ROOT_AGENT_DIR/.gemini/core/ai-bridge.sh" "gemini-3-flash-preview" "$PROMPT_TMP" > "$ENDPOINT_DIR/$TARGET_FILE"
        fi
    done
fi

# 3. Limpieza GraphQL
if [ "$GW_MODE" == "rest" ]; then
    echo -e "${YELLOW}🧹 Limpiando GraphQL en '$ENDPOINT_NAME'...${NC}"
    find "$ENDPOINT_DIR" -name "*.ts" -exec sh -c 'source "'"$ROOT_AGENT_DIR"'/.gemini/core/utils.sh"; clean_graphql_artifacts "$1"' _ {} \;
fi

# 4. Registro y Calidad
echo -e "${BLUE}🔗 Sincronizando...${NC}"
bash "$ROOT_AGENT_DIR/.gemini/core/sync-appmodule-endpoints.sh"

if type ensure_quality_standards >/dev/null 2>&1; then
    echo -e "${BLUE}🧪 Iniciando Garante de Calidad...${NC}"
    ensure_quality_standards || echo -e "${YELLOW}⚠️ Advertencia: Cobertura parcial en '$ENDPOINT_NAME'.${NC}"
fi

echo -e "${GREEN}✅ Módulo '$ENDPOINT_NAME' listo.${NC}"
