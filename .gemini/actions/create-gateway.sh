#!/bin/bash
# .gemini/actions/create-gateway.sh

NAME=$1
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configurar rutas absolutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_AGENT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TPL_DIR="$ROOT_AGENT_DIR/.gemini/.templates/templates-gateway"
ACTIONS_DIR=".gemini/actions"

# Importar utilidades de IA si existen
if [ -f "$ROOT_AGENT_DIR/.gemini/core/utils.sh" ]; then
    source "$ROOT_AGENT_DIR/.gemini/core/utils.sh"
fi

if [ -z "$NAME" ]; then
    CURRENT_FOLDER=$(basename "$PWD")
    read -p "Nombre del API Gateway [$CURRENT_FOLDER]: " INPUT_NAME
    NAME="${INPUT_NAME:-$CURRENT_FOLDER}"
fi

# 1. Crear proyecto Nest base en temporal
echo -e "${BLUE}Creando proyecto base con Nest CLI (temp)...${NC}"
TEMP_DIR="temp_gateway_scaffold"
rm -rf "$TEMP_DIR"

if command -v nest >/dev/null 2>&1; then
    nest new "$TEMP_DIR" --strict --skip-git --package-manager npm >/dev/null
else
    npx @nestjs/cli new "$TEMP_DIR" --strict --skip-git --package-manager npm >/dev/null
fi

# 2. Mover a la raíz
echo -e "${BLUE}Migrando archivos a la raíz...${NC}"
cp -R "$TEMP_DIR/"* . 2>/dev/null
cp -R "$TEMP_DIR/."* . 2>/dev/null
rm -rf "$TEMP_DIR"

# 3. Renombrar en package.json
sed -i '' "s/\"name\": \"$TEMP_DIR\"/\"name\": \"$NAME\"/" package.json 2>/dev/null || sed -i "s/\"name\": \"$TEMP_DIR\"/\"name\": \"$NAME\"/" package.json

# 4. Inyectar Main y AppModule
cp "$TPL_DIR/main.ts.tpl" "src/main.ts"
cp "$TPL_DIR/app.module.ts.tpl" "src/app.module.ts"

# 5. Copiar carpetas base y configuración (Manejo de TPL)
echo -e "${BLUE}Copiando plantillas y configuraciones...${NC}"

# Copiar .env
if [ -f "$TPL_DIR/.env.tpl" ]; then
    cp "$TPL_DIR/.env.tpl" ".env"
elif [ -f "$TPL_DIR/.env" ]; then
    cp "$TPL_DIR/.env" ".env"
fi

# Función para copiar y renombrar recursivamente
copy_tpl_folder() {
    local src_folder="$1"
    local dest_folder="$2"

    if [ -d "$src_folder" ]; then
        echo -e "${BLUE}Copiando $(basename "$src_folder")...${NC}"
        cp -r "$src_folder" "src/"
        
        # Renombrar recursivamente .tpl -> .ts en destino
        find "src/$(basename "$src_folder")" -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}.ts"' _ {} \;
    fi
}

copy_tpl_folder "$TPL_DIR/commons" "src/commons"
copy_tpl_folder "$TPL_DIR/dto" "src/dto"

# 6. Limpieza de boilerplate
rm -f "src/app.controller.ts" "src/app.service.ts" "src/app.controller.spec.ts"

# 7. Gitignore (Append)
cat <<EOF >> ".gitignore"

# Developer Agent
AGENT.md
dev-agent.sh
.gemini/
EOF

# 8. Generación Dinámica de Endpoints (Escaneo de Templates)
echo -e "${YELLOW}Generando endpoints detectados en templates...${NC}"
mkdir -p src/endpoint

# Ruta de los templates de endpoints
ENDPOINTS_TPL_DIR="$ROOT_AGENT_DIR/.gemini/.templates/templates-gateway-endpoint"

if [ -d "$ENDPOINTS_TPL_DIR" ]; then
    # Iterar sobre cada carpeta dentro de templates-gateway-endpoint
    for d in "$ENDPOINTS_TPL_DIR"/*/; do
        if [ -d "$d" ]; then
            ENDPOINT_NAME=$(basename "$d")
            
            # Evitar archivos sueltos o carpetas ocultas
            [[ "$ENDPOINT_NAME" == .* ]] && continue
            
            echo -e "${BLUE}>>> Instalando módulo '$ENDPOINT_NAME'...${NC}"
            
            # Ejecutar el script de creación para este endpoint usando RUTA ABSOLUTA
            bash "$ROOT_AGENT_DIR/$ACTIONS_DIR/create-gateway-endpoint.sh" "$ENDPOINT_NAME" "DefaultMethod" "default-route" "Get" "SERVICE_URL" "/api" "/v1"
        fi
    done
else
    echo -e "${RED}⚠ No se encontraron templates de endpoints en $ENDPOINTS_TPL_DIR${NC}"
fi

# 9. Bucle de Auto-Reparación de Dependencias
echo -e "${BLUE}Iniciando ciclo de auto-reparación de dependencias...${NC}"

# Instalación inicial de las más obvias
echo -e "${YELLOW}Instalando bases (dotenv, axios, class-validator)...${NC}"
npm install --save dotenv @nestjs/config @nestjs/axios axios class-validator class-transformer @nestjs/platform-express

MAX_RETRIES=10
RETRY_COUNT=0
SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
    echo -e "${BLUE}Intento de compilación $((RETRY_COUNT+1))/$MAX_RETRIES...${NC}"
    
    npm run build > build_output.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ El servicio ha compilado correctamente.${NC}"
        SUCCESS=true
    else
        MISSING_MODULE=$(grep -oE "Cannot find module '@?[a-zA-Z0-9/-]+'|Could not find a declaration file for module '@?[a-zA-Z0-9/-]+'" build_output.log | head -1 | grep -oE "'@?[a-zA-Z0-9/-]+'" | tr -d "'")
        
        if [ -n "$MISSING_MODULE" ]; then
            echo -e "${YELLOW}⚠ Falta el módulo: $MISSING_MODULE. Instalando...${NC}"
            npm install --save "$MISSING_MODULE"
            RETRY_COUNT=$((RETRY_COUNT+1))
        else
            FAILED_FILE=$(grep -oE "src/[a-zA-Z0-9/._-]+\.ts" build_output.log | head -1)

            if [ -n "$FAILED_FILE" ] && type run_with_autofix >/dev/null 2>&1; then
                echo -e "${YELLOW}🤖 Error de sintaxis o lógica detectado en $FAILED_FILE. Invocando Agente IA...${NC}"
                
                if run_with_autofix "npm run build" "$FAILED_FILE"; then
                    SUCCESS=true
                    break
                else
                    echo -e "${RED}✘ La IA no pudo arreglar el código. Abortando.${NC}"
                    break
                fi
            else
                echo -e "${RED}✘ Error de compilación no recuperable o IA no disponible.${NC}"
                cat build_output.log | tail -n 10
                break
            fi
        fi
    fi
done

rm -f build_output.log

# 10. Aplicar Templates Globales
apply_global_templates "."

if [ "$SUCCESS" = true ]; then
    echo -e "${BLUE}🚀 Verificación de Runtime Obligatoria (Regla runtime-verification.md)...${NC}"
    
    # Validar integridad de AppModule
    echo -e "${BLUE}🔍 Validando integridad de AppModule...${NC}"
    if grep -q "@Module" src/app.module.ts && grep -q "ConfigSiteModule" src/app.module.ts; then
        echo -e "${GREEN}✔ AppModule validado correctamente.${NC}"
    else
        echo -e "${RED}✘ Error de integridad en AppModule. Invocando IA para sanación...${NC}"
        run_with_autofix "grep '@Module' src/app.module.ts && grep 'ConfigSiteModule' src/app.module.ts" "src/app.module.ts"
    fi

    echo -e "${BLUE}Iniciando servidor para prueba de vida (15s)...${NC}"
    npm run start:dev > runtime.log 2>&1 &
    SERVER_PID=$!
    sleep 15
    
    if kill -0 $SERVER_PID 2>/dev/null; then
        echo -e "${GREEN}✅ El servidor arrancó y se mantuvo estable.${NC}"
        kill $SERVER_PID
        SUCCESS_RUNTIME=true
    else
        echo -e "${RED}❌ El servidor crasheó antes de 15 segundos.${NC}"
        cat runtime.log | tail -n 20
        SUCCESS_RUNTIME=false
    fi

    if [ "$SUCCESS_RUNTIME" = true ]; then
        echo -e "${GREEN}✅ API Gateway '$NAME' verificado en runtime exitosamente.${NC}"
        
        echo -e "${BLUE}🧪 Iniciando verificación de Testing y Cobertura (95% min)...${NC}"
        # Ruta corregida del test
        TEST_FILE="src/endpoint/config-site/infrastructure/controller/config-site.controller.spec.ts"
        if run_with_autofix "npm run test:cov" "$TEST_FILE" "test"; then
            echo -e "${GREEN}✅ API Gateway '$NAME' cumple con el 95% de cobertura.${NC}"
        else
            echo -e "${RED}❌ El Gateway no alcanzó la cobertura mínima del 95% o los tests fallan.${NC}"
        fi
    else
        echo -e "${RED}❌ Error de Runtime crítico.${NC}"
    fi
else
    echo -e "${YELLOW}⚠ El Gateway no pudo ser verificado en runtime porque falló la compilación.${NC}"
fi
