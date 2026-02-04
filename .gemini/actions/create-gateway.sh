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

# IMPORTAR UTILIDADES SIEMPRE
if [ -f "$ROOT_AGENT_DIR/.gemini/core/utils.sh" ]; then
    source "$ROOT_AGENT_DIR/.gemini/core/utils.sh"
fi

if [ -z "$NAME" ]; then
    CURRENT_FOLDER=$(basename "$PWD")
    read -p "Nombre del API Gateway [$CURRENT_FOLDER]: " INPUT_NAME
    NAME="${INPUT_NAME:-$CURRENT_FOLDER}"
fi

# 1. Scaffold
TEMP_DIR="temp_gateway_scaffold"
rm -rf "$TEMP_DIR"
npx @nestjs/cli new "$TEMP_DIR" --strict --skip-git --package-manager npm >/dev/null

# 2. Migración
cp -R "$TEMP_DIR/"* . 2>/dev/null
cp -R "$TEMP_DIR/."* . 2>/dev/null
rm -rf "$TEMP_DIR"
sed -i '' "s/\"name\": \"$TEMP_DIR\"/\"name\": \"$NAME\"/" package.json 2>/dev/null || sed -i "s/\"name\": \"$TEMP_DIR\"/\"name\": \"$NAME\"/" package.json
rm -f "src/app.controller.ts" "src/app.service.ts" "src/app.controller.spec.ts"

# 3. Base Templates
# Forzamos la copia del template limpio de app.module.ts al inicio
[ -f "$TPL_DIR/app.module.ts.tpl" ] && cp "$TPL_DIR/app.module.ts.tpl" "src/app.module.ts"
[ -f "$TPL_DIR/main.ts.tpl" ] && cp "$TPL_DIR/main.ts.tpl" "src/main.ts"
[ -f "$TPL_DIR/.env.tpl" ] && cp "$TPL_DIR/.env.tpl" ".env"

copy_tpl_folder() {
    local src_folder="$1"
    local dest_subpath="$2"
    if [ -d "$src_folder" ]; then
        mkdir -p "src/$dest_subpath"
        cp -r "$src_folder/"* "src/$dest_subpath/"
        find "src/$dest_subpath" -path "*/.gemini" -prune -o -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
    fi
}
copy_tpl_folder "$TPL_DIR/commons" "commons"
copy_tpl_folder "$TPL_DIR/dto" "dto"

# Reemplazar placeholders en los archivos generados
echo -e "${BLUE}Personalizando archivos con el nombre del servicio: $NAME...${NC}"
find src -type f -exec sed -i '' "s/{{SERVICE_NAME}}/$NAME/g" {} + 2>/dev/null || \
find src -type f -exec sed -i "s/{{SERVICE_NAME}}/$NAME/g" {} +

# 4. Endpoints Dinámicos (Solo los base)
ENDPOINTS_TPL_DIR="$ROOT_AGENT_DIR/.gemini/.templates/templates-gateway-endpoint"
CREATED_ENDPOINTS=()
if [ -d "$ENDPOINTS_TPL_DIR" ]; then
    for d in "$ENDPOINTS_TPL_DIR"/*/; do
        ENDPOINT_NAME=$(basename "$d")
        [[ "$ENDPOINT_NAME" == .* ]] && continue
        [[ "$ENDPOINT_NAME" == "base-endpoint" ]] && continue
        
        CREATED_ENDPOINTS+=("$ENDPOINT_NAME")
        # Pasamos exactamente 9 argumentos para asegurar que "true" llegue a SKIP_QUALITY
        # 1:Name, 2:Method, 3:Route, 4:HTTP, 5:BaseUrl, 6:ExtPath, 7:Version, 8:Mode, 9:SkipQuality
        bash "$ROOT_AGENT_DIR/$ACTIONS_DIR/create-gateway-endpoint.sh" \
            "$ENDPOINT_NAME" "" "" "" "" "" "/v1" "$GW_MODE" "true"
    done
fi

apply_global_templates "."

# 5. Dependencias
echo -e "${BLUE}📦 Instalando dependencias...${NC}"
BASE_DEPS="dotenv @nestjs/config @nestjs/axios axios class-validator class-transformer @nestjs/platform-express jsonwebtoken @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node @opentelemetry/exporter-trace-otlp-proto @opentelemetry/resources @nestjs/jwt @nestjs/passport passport-jwt"
if [ "$GW_MODE" == "hybrid" ]; then
    npm install --save $BASE_DEPS @nestjs/graphql graphql-tag graphql >/dev/null 2>&1
else
    npm install --save $BASE_DEPS >/dev/null 2>&1
fi
npm install --save-dev @types/jsonwebtoken @types/node @types/passport-jwt >/dev/null 2>&1

# 6. Limpieza GraphQL
if [ "$GW_MODE" == "rest" ]; then
    echo -e "${YELLOW}🧹 Limpiando GraphQL...${NC}"
    find src -name "*.ts" -exec sh -c 'source "'$ROOT_AGENT_DIR'/.gemini/core/utils.sh"; clean_graphql_artifacts "$1"' _ {} \;
fi

# 7. Verificación de Arranque
echo -e "${BLUE}🚀 Verificando arranque del servicio...${NC}"
npm run build >/dev/null 2>&1
if [ $? -eq 0 ]; then
    # Intentar arrancar en segundo plano
    # Usamos PORT 3000 por defecto si no existe en .env
    CHECK_PORT=$(grep "PORT=" .env | cut -d'=' -f2 || echo "3000")
    CHECK_PORT=${CHECK_PORT:-3000}

    npm run start > server_start.log 2>&1 &
    SERVER_PID=$!
    
    echo -e "${YELLOW}⏳ Esperando 10s para validación en puerto $CHECK_PORT...${NC}"
    sleep 10
    
    if lsof -Pi :$CHECK_PORT -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${GREEN}✔ El servicio arrancó correctamente en el puerto $CHECK_PORT.${NC}"
        # Matar todos los procesos en ese puerto (Padre npm e hijos node)
        lsof -ti :$CHECK_PORT | xargs kill -9 2>/dev/null || kill -9 $SERVER_PID
    else
        echo -e "${RED}✘ El servicio falló al arrancar o no respondió en el puerto $CHECK_PORT.${NC}"
        cat server_start.log
        kill -9 $SERVER_PID 2>/dev/null
        exit 1
    fi
    rm -f server_start.log
else
    echo -e "${RED}✘ Fallo en la compilación inicial.${NC}"
    exit 1
fi

# 8. Garante de Calidad Final (Para todos los módulos creados)
echo -e "${BLUE}🛡️ Ejecutando Garante de Calidad para módulos base...${NC}"
for ENDPOINT in "${CREATED_ENDPOINTS[@]}"; do
    # Ejecutamos ahora la calidad explícitamente (SkipQuality = false)
    bash "$ROOT_AGENT_DIR/$ACTIONS_DIR/create-gateway-endpoint.sh" \
        "$ENDPOINT" "" "" "" "" "" "/v1" "$GW_MODE" "false"
done

echo -e "${GREEN}✨ API Gateway '$NAME' generado con éxito.${NC}"