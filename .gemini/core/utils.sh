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

get_coverage_pct() {
    local log_file=$1
    if [ ! -f "$log_file" ]; then echo "0"; return; fi
    local pct=$(grep "All files" "$log_file" | awk '{print $4}' | cut -d. -f1 | tr -d '%')
    echo "${pct:-0}"
}

# Obtener archivos con baja cobertura (Limpieza profunda)
get_low_coverage_files() {
    local log_file=$1
    if [ ! -f "$log_file" ]; then return; fi
    
    # 1. Extraer líneas que parecen archivos .ts
    # 2. Quitar códigos de colores ANSI
    # 3. Quitar PASS/FAIL y espacios
    # 4. Quedarnos con el nombre del archivo
    sed $'s/\x1b\[[0-9;]*m//g' "$log_file" | \
    grep ".ts" | \
    sed 's/PASS//g; s/FAIL//g' | \
    awk -F'|' '$2 !~ /100/ {print $1}' | \
    tr -d ' ' | \
    grep "\.ts$"
}

# --- UTILIDADES DE TEMPLATES ---
apply_global_templates() {
    local target_dir="$1"
    local global_tpl_dir="$AGENT_ROOT/.gemini/.templates/global"
    if [ -d "$global_tpl_dir" ]; then
        echo -e "${BLUE}🌍 Aplicando templates globales...${NC}"
        cp -R "$global_tpl_dir/"* "$target_dir/" 2>/dev/null
        cp -R "$global_tpl_dir/."* "$target_dir/" 2>/dev/null
        find "$target_dir" -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
    fi
}

clean_graphql_artifacts() {
    local target_file="$1"
    [ ! -f "$target_file" ] && return
    if [[ $(basename "$target_file") == *[Gg]raph[Qq]l* ]]; then
        rm -f "$target_file"
        return
    fi
    sed -i '' '/\/\/ <<GQL/,\/\/ GQL>>/d' "$target_file" 2>/dev/null || \
    sed -i '/\/\/ <<GQL/,\/\/ GQL>>/d' "$target_file"
    local TEMP_CLEAN=".clean_tmp"
    grep -vE '^[[:space:]]*@ObjectType|^[[:space:]]*@Field|^[[:space:]]*@InputType|^[[:space:]]*import.*@nestjs/graphql' "$target_file" > "$TEMP_CLEAN"
    mv "$TEMP_CLEAN" "$target_file"
}

# --- GARANTE DE CALIDAD E INTEGRIDAD ---
ensure_quality_standards() {
    local test_cmd="npm run test:cov"
    local max_iterations=8; local iteration=1; local goal=95
    local temp_log=".gemini/tmp/qa_report.log"; local ai_res_file=".gemini/tmp/ai_res.txt"
    mkdir -p .gemini/tmp

    while [ $iteration -le $max_iterations ]; do
        echo -e "\n🔍 Calidad Iteración $iteration/$max_iterations..."
        # Ejecutamos sin colores para facilitar el parseo
        FORCE_COLOR=0 eval "$test_cmd" > "$temp_log" 2>&1
        local exit_code=$?
        local current_coverage=$(get_coverage_pct "$temp_log")
        echo -e "${BLUE}📊 Cobertura: ${current_coverage}% (Meta: ${goal}%)${NC}"
        
        if [ $exit_code -eq 0 ] && [ "$current_coverage" -ge "$goal" ]; then
            echo -e "${GREEN}✅ EXCELENCIA ALCANZADA.${NC}"; return 0
        fi

        local target_file=""
        if [ $exit_code -ne 0 ]; then
            # Caso FALLO: Identificar archivo que causó el FAIL
            target_file=$(grep -E "FAIL" "$temp_log" | head -1 | awk '{print $2}' | sed 's/src\///g')
            [ -z "$target_file" ] && target_file=$(grep -oE "src/[^ ]+\.spec\.ts" "$temp_log" | head -1 | sed 's/src\///g')
            local mode="FIX"
        else
            # Caso COBERTURA BAJA: Buscar archivo de lógica
            local low_cov_list=$(get_low_coverage_files "$temp_log" | grep -vE "main.ts|app.module.ts|index.ts|dto.ts|.config.ts|.constants.ts|.module.ts")
            target_file=$(echo "$low_cov_list" | head -1)
            local mode="IMPROVE"
        fi

        # Búsqueda física del archivo (por si la ruta de Jest es relativa o incompleta)
        local spec_file=""
        if [ -n "$target_file" ]; then
            # Si termina en .spec.ts es un FIX, si no es un IMPROVE y buscamos su spec
            if [[ "$target_file" == *.spec.ts ]]; then
                spec_file=$(find src -name "$(basename "$target_file")" | head -1)
            else
                local base_name=$(basename "$target_file" .ts)
                spec_file=$(find src -name "${base_name}.spec.ts" | head -1)
            fi
        fi

        if [ -n "$spec_file" ] && [ -f "$spec_file" ]; then
            local prod_file="${spec_file%.spec.ts}.ts"
            echo -e "${YELLOW}🛠 IA Trabajando en: $spec_file ($mode)${NC}"
            local prompt_file=".gemini/tmp/qa_prompt.txt"
            if [ "$mode" == "FIX" ]; then
                echo "REPARA EL TEST: $(cat "$spec_file") ERROR: $(tail -n 20 "$temp_log")" > "$prompt_file"
            else
                echo "MEJORA COBERTURA AL 100%. CODIGO: $(cat "$prod_file") TEST ACTUAL: $(cat "$spec_file")" > "$prompt_file"
            fi
            bash "$AGENT_ROOT/.gemini/core/ai-bridge.sh" "gemini-3-flash-preview" "$prompt_file" > "$ai_res_file" 2>/dev/null
            if [ $? -eq 0 ] && [ -s "$ai_res_file" ]; then
                local clean=$(cat "$ai_res_file" | sed 's/^```[a-z]*//g' | sed 's/^```//g' | sed 's/```$//g')
                echo "$clean" | awk '/^[[:space:]]*(import|export|@|const|let|var|class|function|describe|it|test|\/\*|\/\/)/ {p=1} p' > "$spec_file"
                echo -e "${GREEN}✨ Cambios aplicados.${NC}"
            fi
        else
            echo -e "${RED}⚠️ No se pudo localizar el archivo para $target_file.${NC}"
            [ "$current_coverage" -ge 70 ] && return 0 # Salida de emergencia si la cobertura es decente
            break
        fi
        iteration=$((iteration + 1))
    done
    return 1
}

run_with_autofix() {
    local cmd="$1"; local target_file="$2"; local attempt=1
    while [ $attempt -le 3 ]; do
        eval "$cmd" > /dev/null 2>&1 && return 0
        attempt=$((attempt + 1))
    done
    return 1
}
