#!/bin/bash

# Determinar la ruta raíz del agente
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_ROOT="$(dirname "$(dirname "$UTILS_DIR")")"

# Colores para la consola
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Función de limpieza definitiva de GraphQL (Shell Estándar)
clean_graphql_artifacts() {
    local target_file="$1"
    [ ! -f "$target_file" ] && return

    # 1. Eliminar archivos que contengan "graphql" en el nombre
    if [[ $(basename "$target_file") == *[Gg]raph[Qq]l* ]]; then
        rm -f "$target_file"
        return
    fi

    # 2. Borrar bloques marcados con etiquetas
    sed -i '' '/\/\/ <<GQL/,/\/\/ GQL>>/d' "$target_file" 2>/dev/null || \
    sed -i '/\/\/ <<GQL/,/\/\/ GQL>>/d' "$target_file"

    # 3. Borrar decoradores aislados en DTOs
    local TEMP_CLEAN=".clean_tmp"
    grep -vE '^[[:space:]]*@ObjectType|^[[:space:]]*@Field|^[[:space:]]*@InputType|^[[:space:]]*import.*@nestjs/graphql' "$target_file" > "$TEMP_CLEAN"
    mv "$TEMP_CLEAN" "$target_file"
}

apply_global_templates() {
    local target_dir="$1"
    local global_tpl_dir="$AGENT_ROOT/.gemini/.templates/global"
    if [ -d "$global_tpl_dir" ]; then
        echo -e "${BLUE}🌍 Aplicando templates globales...${NC}"
        # Copiar sin afectar .gemini
        cp -R "$global_tpl_dir/"* "$target_dir/" 2>/dev/null
        cp -R "$global_tpl_dir/."* "$target_dir/" 2>/dev/null
        
        # CORRECCIóN: El find ahora ignora la carpeta .gemini
        find "$target_dir" -path "*/.gemini" -prune -o -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
    fi
}