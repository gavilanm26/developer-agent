#!/bin/bash
# .gemini/actions/create-gateway.sh

NAME=$1
GW_MODE=${2:-hybrid}
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_AGENT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TPL_DIR="$ROOT_AGENT_DIR/.gemini/.templates/templates-gateway"
ACTIONS_DIR=".gemini/actions"

if [ -f "$ROOT_AGENT_DIR/.gemini/core/utils.sh" ]; then
    source "$ROOT_AGENT_DIR/.gemini/core/utils.sh"
fi

if [ -z "$NAME" ]; then
    CURRENT_FOLDER=$(basename "$PWD")
    read -p "Nombre del API Gateway [$CURRENT_FOLDER]: " INPUT_NAME
    NAME="${INPUT_NAME:-$CURRENT_FOLDER}"
fi

# 1. Scaffold Base
TEMP_DIR="temp_gateway_scaffold"
rm -rf "$TEMP_DIR"
npx @nestjs/cli new "$TEMP_DIR" --strict --skip-git --package-manager npm >/dev/null

# 2. Migración
cp -R "$TEMP_DIR/"* . 2>/dev/null
cp -R "$TEMP_DIR/."* . 2>/dev/null
rm -rf "$TEMP_DIR"
sed -i '' "s/\"name\": \"$TEMP_DIR\"/\"name\": \"$NAME\"/" package.json 2>/dev/null || sed -i "s/\"name\": \"$TEMP_DIR\"/\"name\": \"$NAME\"/" package.json
rm -f "src/app.controller.ts" "src/app.service.ts" "src/app.controller.spec.ts"

# 3. Inyectar Templates Base (Manejo genérico de .tpl)
[ -f "$TPL_DIR/main.ts.tpl" ] && cp "$TPL_DIR/main.ts.tpl" "src/main.ts"
[ -f "$TPL_DIR/app.module.ts.tpl" ] && cp "$TPL_DIR/app.module.ts.tpl" "src/app.module.ts"
[ -f "$TPL_DIR/.env.tpl" ] && cp "$TPL_DIR/.env.tpl" ".env"

copy_tpl_folder() {
    local src_folder="$1"
    local dest_subpath="$2"
    if [ -d "$src_folder" ]; then
        mkdir -p "src/$dest_subpath"
        cp -r "$src_folder/"* "src/$dest_subpath/"
        # Quitar extensión .tpl recursivamente (Ignorando .gemini por seguridad)
        find "src/$dest_subpath" -path "*/.gemini" -prune -o -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
    fi
}

copy_tpl_folder "$TPL_DIR/commons" "commons"
copy_tpl_folder "$TPL_DIR/dto" "dto"

# 4. Endpoints Dinámicos
ENDPOINTS_TPL_DIR="$ROOT_AGENT_DIR/.gemini/.templates/templates-gateway-endpoint"
if [ -d "$ENDPOINTS_TPL_DIR" ]; then
    for d in "$ENDPOINTS_TPL_DIR"/*/; do
        ENDPOINT_NAME=$(basename "$d")
        [[ "$ENDPOINT_NAME" == .* ]] && continue
        bash "$ROOT_AGENT_DIR/$ACTIONS_DIR/create-gateway-endpoint.sh" "$ENDPOINT_NAME" "Default" "route" "Get" "URL" "/api" "/v1" "$GW_MODE"
    done
fi

# 5. Templates Globales
apply_global_templates "."

# 6. LIMPIEZA CRÍTICA (Solo si es REST)
if [ "$GW_MODE" == "rest" ]; then
    echo -e "${YELLOW}🧹 Limpiando rastro de GraphQL...${NC}"
    find src -name "*.ts" -exec sh -c 'source "'$ROOT_AGENT_DIR'/.gemini/core/utils.sh"; clean_graphql_artifacts "$1"' _ {} \;
fi

# 7. Dependencias
echo -e "${BLUE}Instalando dependencias...${NC}"
BASE_DEPS="dotenv @nestjs/config @nestjs/axios axios class-validator class-transformer @nestjs/platform-express jsonwebtoken @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node @opentelemetry/exporter-trace-otlp-proto @opentelemetry/resources @nestjs/jwt @nestjs/passport passport-jwt"
if [ "$GW_MODE" == "hybrid" ]; then
    npm install --save $BASE_DEPS @nestjs/graphql graphql-tag graphql
else
    npm install --save $BASE_DEPS
fi
npm install --save-dev @types/jsonwebtoken @types/node @types/passport-jwt

# 8. Verificación Final (BUILD y CALIDAD)
echo -e "${BLUE}Validando compilación...${NC}"
npm run build
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ Compilación Exitosa.${NC}"
    
    echo -e "${BLUE}Iniciando Garante de Calidad (Tests y Cobertura)...${NC}"
    if ensure_quality_standards; then
        echo -e "${GREEN}✔ Gateway '$NAME' creado, compilado y con tests al 100%.${NC}"
    else
        echo -e "${RED}❌ El Gateway no pudo alcanzar los estándares de calidad en los tests.${NC}"
        exit 1
    fi
else
    echo -e "${RED}✘ Error de compilación detectado.${NC}"
    exit 1
fi