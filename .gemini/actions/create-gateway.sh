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
TPL_DIR="$ROOT_AGENT_DIR/.gemini/actions/templates-gateway"
ACTIONS_DIR=".gemini/actions"

# Importar utilidades de IA si existen
if [ -f "$ROOT_AGENT_DIR/.gemini/core/utils.sh" ]; then
    source "$ROOT_AGENT_DIR/.gemini/core/utils.sh"
fi

if [ -z "$NAME" ]; then
    read -p "Nombre del API Gateway (kebab-case): " NAME
fi

# 1. Crear proyecto Nest base
echo -e "${BLUE}Creando proyecto base con Nest CLI...${NC}"
if command -v nest >/dev/null 2>&1; then
    nest new "$NAME" --strict --skip-git --package-manager npm
else
    npx @nestjs/cli new "$NAME" --strict --skip-git --package-manager npm
fi

# 2. Inyectar Main y AppModule
cp "$TPL_DIR/main.ts.tpl" "$NAME/src/main.ts"
cp "$TPL_DIR/app.module.ts.tpl" "$NAME/src/app.module.ts"

# 3. Copiar carpeta commons, dto y archivos de configuración
if [ -d "$TPL_DIR/commons" ]; then
    echo -e "${BLUE}Copiando carpeta commons...${NC}"
    cp -r "$TPL_DIR/commons" "$NAME/src/"
fi

if [ -d "$TPL_DIR/dto" ]; then
    echo -e "${BLUE}Copiando carpeta dto...${NC}"
    cp -r "$TPL_DIR/dto" "$NAME/src/"
fi

if [ -f "$TPL_DIR/.env" ]; then
    echo -e "${BLUE}Copiando archivo .env...${NC}"
    cp "$TPL_DIR/.env" "$NAME/.env"
fi

# 4. Limpieza de boilerplate
rm -f "$NAME/src/app.controller.ts" "$NAME/src/app.service.ts" "$NAME/src/app.controller.spec.ts"

# 5. Gitignore
cat <<EOF > "$NAME/.gitignore"
/dist
/node_modules
.env
.DS_Store
AGENT.md
dev-agent.sh
.gemini/
EOF

# 6. Crear endpoint obligatorio config-site
echo -e "${YELLOW}Generando endpoint obligatorio 'config-site'...${NC}"
cd "$NAME"
mkdir -p src/endpoint
bash "../$ACTIONS_DIR/create-gateway-endpoint.sh" "config-site" "getConfig" "" "Get" "CONFIG_SERVICE_URL" "/site/configuration" "/v1"

# 7. Bucle de Auto-Reparación de Dependencias
echo -e "${BLUE}Iniciando ciclo de auto-reparación de dependencias...${NC}"

# Instalación inicial de las más obvias para ahorrar tiempo
echo -e "${YELLOW}Instalando bases (dotenv, axios, class-validator)...${NC}"
npm install --save dotenv @nestjs/config @nestjs/axios axios class-validator class-transformer @nestjs/platform-express

MAX_RETRIES=10
RETRY_COUNT=0
SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
    echo -e "${BLUE}Intento de compilación $((RETRY_COUNT+1))/$MAX_RETRIES...${NC}"
    
    # Intentamos compilar el proyecto
    # Guardamos el error en un archivo temporal
    npm run build > build_output.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ El servicio ha compilado correctamente.${NC}"
        SUCCESS=true
    else
        # Buscamos el error "Cannot find module 'X'" o "Cannot find type definition for 'X'"
        MISSING_MODULE=$(grep -oE "Cannot find module '@?[a-zA-Z0-9/-]+'|Could not find a declaration file for module '@?[a-zA-Z0-9/-]+'" build_output.log | head -1 | grep -oE "'@?[a-zA-Z0-9/-]+'" | tr -d "'")
        
        if [ -n "$MISSING_MODULE" ]; then
            echo -e "${YELLOW}⚠ Falta el módulo: $MISSING_MODULE. Instalando...${NC}"
            npm install --save "$MISSING_MODULE"
            RETRY_COUNT=$((RETRY_COUNT+1))
        else
            # Intentar identificar el archivo culpable (buscando src/*.ts en el log)
            FAILED_FILE=$(grep -oE "src/[a-zA-Z0-9/._-]+\.ts" build_output.log | head -1)

            if [ -n "$FAILED_FILE" ] && type run_with_autofix >/dev/null 2>&1; then
                echo -e "${YELLOW}🤖 Error de sintaxis o lógica detectado en $FAILED_FILE. Invocando Agente IA...${NC}"
                
                # Invocamos la utilidad de IA
                if run_with_autofix "npm run build" "$FAILED_FILE"; then
                    SUCCESS=true
                    break
                else
                    echo -e "${RED}✘ La IA no pudo arreglar el código (posible falta de cuota). Abortando para ahorrar tiempo.${NC}"
                    break # SALIDA INMEDIATA si la IA falla
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
cd ..

if [ "$SUCCESS" = true ]; then
    echo -e "${BLUE}🚀 Verificación de Runtime Obligatoria (Regla runtime-verification.md)...${NC}"
    
    # Entramos al directorio con ruta absoluta para evitar errores de uv_cwd (directorio borrado/recreado)
    cd "$ROOT_AGENT_DIR/$NAME" || exit
    
    # Intentamos arrancar. La IA reparará si hay errores de inyección o lógica de arranque.
    if run_with_autofix "timeout 15s npm run start:dev" "src/main.ts"; then
        echo -e "${GREEN}✅ API Gateway '$NAME' verificado en runtime exitosamente.${NC}"
        
        # NUEVO: Verificación de Tests y Cobertura
        echo -e "${BLUE}🧪 Iniciando verificación de Testing y Cobertura (95% min)...${NC}"
        # Intentamos arreglar el test del controlador base si la cobertura es baja
        if run_with_autofix "npm run test:cov" "src/endpoint/config-site/infrastructure/controller/config-site.controller.spec.ts" "test"; then
            echo -e "${GREEN}✅ API Gateway '$NAME' cumple con el 95% de cobertura.${NC}"
        else
            echo -e "${RED}❌ El Gateway no alcanzó la cobertura mínima del 95% o los tests fallan.${NC}"
        fi
    else
        echo -e "${RED}❌ Error de Runtime crítico. El servicio no arranca tras reparaciones.${NC}"
    fi
else
    echo -e "${YELLOW}⚠ El Gateway no pudo ser verificado en runtime porque falló la compilación.${NC}"
fi
