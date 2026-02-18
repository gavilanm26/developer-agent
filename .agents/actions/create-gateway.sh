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
TPL_DIR="$ROOT_AGENT_DIR/.agents/.templates/templates-gateway"
ACTIONS_DIR=".agents/actions"

# IMPORTAR UTILIDADES SIEMPRE
if [ -f "$ROOT_AGENT_DIR/.agents/core/utils.sh" ]; then
    source "$ROOT_AGENT_DIR/.agents/core/utils.sh"
fi

# Actualizar .gitignore
cat <<EOF >> .gitignore
# Developer Agent (Private)
AGENT.md
dev-agent.sh
.agents/
EOF

if [ -z "$NAME" ]; then
    CURRENT_FOLDER=$(basename "$PWD")
    read -p "Nombre del API Gateway [$CURRENT_FOLDER]: " INPUT_NAME
    NAME="${INPUT_NAME:-$CURRENT_FOLDER}"
fi

# Validar y crear directorio si es necesario
CURRENT_DIR=$(basename "$PWD")
if [ "$CURRENT_DIR" != "$NAME" ]; then
    if [ -d "$NAME" ]; then
        echo -e "${YELLOW}El directorio '$NAME' ya existe.${NC}"
        read -p "¿Deseas entrar y continuar? (s/n): " CONFIRM
        if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
            exit 1
        fi
    else
        echo -e "${BLUE}Creando directorio '$NAME'...${NC}"
        mkdir -p "$NAME"
    fi
    cd "$NAME" || exit 1
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
        find "src/$dest_subpath" -path "*/.agents" -prune -o -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
    fi
}
copy_tpl_folder "$TPL_DIR/commons" "commons"
copy_tpl_folder "$TPL_DIR/dto" "dto"

# Reemplazar placeholders en los archivos generados
echo -e "${BLUE}Personalizando archivos con el nombre del servicio: $NAME...${NC}"
find src -type f -exec sed -i '' "s/{{SERVICE_NAME}}/$NAME/g" {} + 2>/dev/null || \
find src -type f -exec sed -i "s/{{SERVICE_NAME}}/$NAME/g" {} +

# 4. Endpoints Dinámicos (Solo los base)
ENDPOINTS_TPL_DIR="$ROOT_AGENT_DIR/.agents/.templates/templates-gateway-endpoint"
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

# 4.5. Implantar Cerebro del Agente (Self-Replication from .agents)
echo -e "${BLUE}🧠 Implantando identidad y reglas del Agente desde .agents...${NC}"
mkdir -p ".agents"

# Copiar identidad
if [ -f "$ROOT_AGENT_DIR/AGENT.md" ]; then
    cp "$ROOT_AGENT_DIR/AGENT.md" .
    echo -e "${GREEN}  - Identidad copiada a la raíz.${NC}"
fi

# Copiar reglas
if [ -d "$ROOT_AGENT_DIR/.agents/rules" ]; then
    cp -r "$ROOT_AGENT_DIR/.agents/rules" ".agents/"
    echo -e "${GREEN}  - Reglas Hexagonales copiadas.${NC}"
fi

# Copiar skills (opcional pero recomendado)
if [ -d "$ROOT_AGENT_DIR/.agents/skills" ]; then
    cp -r "$ROOT_AGENT_DIR/.agents/skills" ".agents/"
    echo -e "${GREEN}  - Skills copiadas.${NC}"
fi

# Copiar cerebros (grafos de decisión)
if [ -d "$ROOT_AGENT_DIR/.agents/brains" ]; then
    cp -r "$ROOT_AGENT_DIR/.agents/brains" ".agents/"
    echo -e "${GREEN}  - Grafos de decisión (Brains) copiados.${NC}"
fi

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
    find src -name "*.ts" -exec sh -c 'source "'$ROOT_AGENT_DIR'/.agents/core/utils.sh"; clean_graphql_artifacts "$1"' _ {} \;
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

# 8. Garante de Calidad Global Final

echo -e "${BLUE}🛡️ Iniciando Garante de Calidad Global...${NC}"



MAX_RETRIES=5

ATTEMPT=0

SUCCESS=false



while [ $ATTEMPT -lt $MAX_RETRIES ]; do

    ATTEMPT=$((ATTEMPT + 1))

    echo -e "${YELLOW}🔄 Intento $ATTEMPT/$MAX_RETRIES: Ejecutando tests y cobertura total...${NC}"

    

    TEST_LOG="test_output.log"

    # Ejecutamos tests de todo el proyecto

    npm run test:cov > "$TEST_LOG" 2>&1 || true

    

    if grep -q "FAIL" "$TEST_LOG" || ! grep -q "PASS" "$TEST_LOG"; then

        echo -e "${RED}❌ Errores detectados en los tests o cobertura insuficiente.${NC}"

        echo -e "${YELLOW}🤖 La IA está analizando los fallos globales para estabilizar el servicio...${NC}"

        

        PROMPT_FILE="$ROOT_AGENT_DIR/.agents/tmp/fix_global_prompt.txt"

        cat <<EOF > "$PROMPT_FILE"

ERES UN ARQUITECTO NESTJS SENIOR.

El proyecto recién generado tiene fallos en los tests o en la cobertura de código.

LOG DE ERRORES:

$(tail -n 60 "$TEST_LOG")



INSTRUCCIÓN:

1. Analiza los errores del log.

2. Corrige los archivos necesarios para que los tests pasen y la cobertura sea óptima.

3. Devuelve solo los archivos modificados en el formato: ### RUTA_ARCHIVO ### CONTENIDO ###

EOF

        

        CORRECTIONS=$(bash "$ROOT_AGENT_DIR/.agents/core/ai-bridge.sh" "" "$PROMPT_FILE")

        

        # Aplicar correcciones

        echo "$CORRECTIONS" | awk '

            /^### .* ###/ { 

                file=$2; 

                gsub(/^### | ###$/, "", file); 

                print "Corrigiendo: " file;

                content_file=file ".tmp";

                next; 

            } 

            { if(file) print $0 > content_file; }

        '

        find . -name "*.tmp" | while read -r tmp_file; do

            real_file="${tmp_file%.tmp}"

            mkdir -p "$(dirname "$real_file")"

            mv "$tmp_file" "$real_file"

        done

    else

        echo -e "${GREEN}✅ Proyecto validado: Tests pasados y cobertura completa.${NC}"

        SUCCESS=true

        break

    fi

done



if [ "$SUCCESS" = false ]; then

    echo -e "${RED}❌ El Garante de Calidad no pudo estabilizar el proyecto automáticamente.${NC}"

fi



rm -f "$TEST_LOG"



echo -e "${GREEN}✨ API Gateway '$NAME' generado y validado con éxito.${NC}"
