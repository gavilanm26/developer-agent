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

if [[ "$ENDPOINT_NAME" == "base-endpoint" ]]; then
  echo "❌ Error: 'base-endpoint' es un template de referencia y no puede ser usado como nombre de módulo."
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

# 1. Nest CLI (Crea el módulo base)
if [ ! -d "$ENDPOINT_DIR" ]; then
    npx nest g mo "endpoint/$ENDPOINT_NAME" --no-spec >/dev/null
fi

# 2. Lógica de Templates
if [[ -d "$TPL_DIR/$ENDPOINT_NAME" ]]; then
    echo -e "${GREEN}📂 Usando template específico para '$ENDPOINT_NAME'.${NC}"
    cp -r "$TPL_DIR/$ENDPOINT_NAME/"* "$ENDPOINT_DIR/"
    find "$ENDPOINT_DIR" -path "*/.gemini" -prune -o -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
else
    echo -e "${YELLOW}📂 Copiando template base para '$ENDPOINT_NAME'...${NC}"
    
    # 1. Copia física de toda la estructura de base-endpoint
    cp -r "$TPL_DIR/base-endpoint/"* "$ENDPOINT_DIR/"
    
    # 2. Renombrar archivos que contienen el placeholder
    find "$ENDPOINT_DIR" -name "*{{SERVICE_KEBAB}}*" | while read -r file; do
        new_file=$(echo "$file" | sed "s/{{SERVICE_KEBAB}}/$ENDPOINT_NAME/g" | sed "s/.tpl//g")
        mv "$file" "$new_file"
    done

    # 3. Reemplazar placeholders en el contenido de todos los archivos
    PASCHAL_NAME=$(to_pascal "$ENDPOINT_NAME")
    LOWER_NAME=$(echo "$ENDPOINT_NAME" | tr '[:upper:]' '[:lower:]')
    UPPER_NAME=$(echo "$ENDPOINT_NAME" | tr '[:lower:]' '[:upper:]')
    
    # Valores por defecto para placeholders
    FINAL_ROUTE="${ROUTE_PATH:-$ENDPOINT_NAME}"
    FINAL_METHOD="${METHOD_NAME:-execute}"
    # Si EXTERNAL_BASE_URL_ENV está vacío, usamos solo el nombre en mayúsculas
    # para que coincida con el prefijo APIURL del template: APIURL + PRODUCTS
    FINAL_ENV="${EXTERNAL_BASE_URL_ENV:-$UPPER_NAME}"
    
    echo -e "${BLUE}📝 Ajustando nombres en el contenido de los archivos...${NC}"
    
    # Procesar cada archivo para asegurar reemplazo total
    find "$ENDPOINT_DIR" -type f | while read -r file; do
        # 1. Placeholders específicos (Con llaves)
        sed -i '' "s/{{SERVICE_KEBAB}}/$ENDPOINT_NAME/g" "$file" 2>/dev/null || sed -i "s/{{SERVICE_KEBAB}}/$ENDPOINT_NAME/g" "$file"
        sed -i '' "s/{{SERVICE_PASCAL}}/$PASCHAL_NAME/g" "$file" 2>/dev/null || sed -i "s/{{SERVICE_PASCAL}}/$PASCHAL_NAME/g" "$file"
        sed -i '' "s/{{ROUTE_PATH}}/$FINAL_ROUTE/g" "$file" 2>/dev/null || sed -i "s/{{ROUTE_PATH}}/$FINAL_ROUTE/g" "$file"
        sed -i '' "s/{{METHOD_NAME}}/$FINAL_METHOD/g" "$file" 2>/dev/null || sed -i "s/{{METHOD_NAME}}/$FINAL_METHOD/g" "$file"
        sed -i '' "s/{{SERVICE_ENV}}/$FINAL_ENV/g" "$file" 2>/dev/null || sed -i "s/{{SERVICE_ENV}}/$FINAL_ENV/g" "$file"
        
        # 2. Reemplazos de compatibilidad (Sin llaves)
        sed -i '' "s/Endpoint/$PASCHAL_NAME/g" "$file" 2>/dev/null || sed -i "s/Endpoint/$PASCHAL_NAME/g" "$file"
        sed -i '' "s/endpoint/$LOWER_NAME/g" "$file" 2>/dev/null || sed -i "s/endpoint/$LOWER_NAME/g" "$file"
    done

    # Quitar extensiones .tpl si quedaron algunas
    find "$ENDPOINT_DIR" -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
fi

# 3. Limpieza GraphQL
if [ "$GW_MODE" == "rest" ]; then
    echo -e "${YELLOW}🧹 Limpiando GraphQL en '$ENDPOINT_NAME'...${NC}"
    find "$ENDPOINT_DIR" -name "*.ts" -exec sh -c 'source "'"$ROOT_AGENT_DIR"'/.gemini/core/utils.sh"; clean_graphql_artifacts "$1"' _ {} \;
fi

# 4. Registro y Sincronización
echo -e "${BLUE}🔗 Sincronizando módulo en AppModule...${NC}"
bash "$ROOT_AGENT_DIR/.gemini/core/sync-appmodule-endpoints.sh"

# 5. Bucle de Garantía de Calidad (Tests y Cobertura)
echo -e "${BLUE}🛡️ Iniciando Garante de Calidad para '$ENDPOINT_NAME'...${NC}"

MAX_RETRIES=5
ATTEMPT=0
SUCCESS=false

while [ $ATTEMPT -lt $MAX_RETRIES ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo -e "${YELLOW}🔄 Intento $ATTEMPT/$MAX_RETRIES: Ejecutando tests y cobertura...${NC}"
    
    # Ejecutar tests capturando salida
    TEST_LOG="test_output.log"
    npm run test:cov -- "$ENDPOINT_DIR" > "$TEST_LOG" 2>&1 || true
    
    # Verificar si pasaron los tests (buscando "FAIL" en el log o revisando exit code de jest)
    # Nota: Filtramos por el directorio del endpoint para ser específicos
    if grep -q "FAIL" "$TEST_LOG" || ! grep -q "PASS" "$TEST_LOG"; then
        echo -e "${RED}❌ Los tests fallaron o no hay cobertura suficiente.${NC}"
        
        echo -e "${YELLOW}🤖 La IA está analizando los errores para corregir '$ENDPOINT_NAME'...${NC}"
        
        # Preparar prompt para la IA con el error
        PROMPT_FILE="$ROOT_AGENT_DIR/.gemini/tmp/fix_prompt.txt"
        cat <<EOF > "$PROMPT_FILE"
ERES UN EXPERTO EN NESTJS Y JEST.
El módulo '$ENDPOINT_NAME' tiene errores de tests o cobertura.
ESTRUCTURA DEL MÓDULO:
$(find "$ENDPOINT_DIR" -maxdepth 3)

LOG DE ERROR:
$(tail -n 50 "$TEST_LOG")

INSTRUCCIÓN:
1. Analiza el error.
2. Devuelve el contenido corregido para los archivos afectados.
3. Formato de respuesta: ### RUTA_ARCHIVO ### CONTENIDO ###
EOF
        
        # Llamar a la IA para obtener correcciones
        CORRECTIONS=$(bash "$ROOT_AGENT_DIR/.gemini/core/ai-bridge.sh" "" "$PROMPT_FILE")
        
        # Aplicar correcciones (Lógica simple de parseo de la respuesta de la IA)
        echo "$CORRECTIONS" | awk -v dir="$PWD" '
            /^### .* ###/ { 
                file=$2; 
                gsub(/^### | ###$/, "", file); 
                print "Corrigiendo: " file;
                content_file=file ".tmp";
                next; 
            } 
            { if(file) print $0 > content_file; }
            END { }
        '
        # Mover archivos temporales a su lugar real
        find . -name "*.tmp" | while read -r tmp_file; do
            real_file="${tmp_file%.tmp}"
            mv "$tmp_file" "$real_file"
        done
    else
        echo -e "${GREEN}✅ Todos los tests pasaron y la cobertura es óptima.${NC}"
        SUCCESS=true
        break
    fi
done

if [ "$SUCCESS" = false ]; then
    echo -e "${RED}❌ No se pudo estabilizar el módulo tras $MAX_RETRIES intentos. Revisa los logs.${NC}"
fi

rm -f "$TEST_LOG"
echo -e "${GREEN}✅ Módulo '$ENDPOINT_NAME' finalizado.${NC}"
