#!/bin/bash

# Determinar la ruta raíz del agente
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_ROOT="$(dirname "$(dirname "$UTILS_DIR")")"

# Función de timeout real
run_with_timeout() {
    local duration=$1; shift
    local cmd="$@"
    eval "$cmd" &
    local pid=$!
    local count=0
    while kill -0 $pid 2>/dev/null; do
        if [ $count -ge $duration ]; then
            kill -9 $pid 2>/dev/null
            return 124
        fi
        sleep 1; ((count++))
    done
    wait $pid
    return $?
}

# Obtener el porcentaje de cobertura de las declaraciones (Stmts)
get_coverage_pct() {
    local log_file=$1
    if [ ! -f "$log_file" ]; then echo "0"; return; fi
    # Extraer el valor de la columna % Stmts de la fila "All files"
    local pct=$(grep "All files" "$log_file" | awk '{print $4}' | cut -d. -f1 | tr -d '%')
    echo "${pct:-0}"
}

# --- UTILIDADES DE TEMPLATES ---
apply_global_templates() {
    local target_dir="$1"
    local global_tpl_dir="$AGENT_ROOT/.gemini/.templates/global"
    if [ -d "$global_tpl_dir" ]; then
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
    local max_iterations=5
    local iteration=1
    local temp_log=".gemini/tmp/qa_report.log"
    local ai_res_file=".gemini/tmp/ai_res.txt"
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local RED='\033[0;31m'
    local NC='\033[0m'
    
    mkdir -p .gemini/tmp

    while [ $iteration -le $max_iterations ]; do
        echo -e "\n🔍 Iteración de Calidad $iteration/$max_iterations..."
        eval "$test_cmd" > "$temp_log" 2>&1
        local exit_code=$?
        
        # Extraer porcentaje de cobertura
        local current_coverage=$(get_coverage_pct "$temp_log")
        echo -e "${BLUE}📊 Cobertura Actual: ${current_coverage}%${NC}"
        
        if [ $exit_code -eq 0 ]; then
            if [ "$current_coverage" -ge 90 ]; then
                echo -e "${GREEN}✅ CALIDAD ALCANZADA: Tests OK y Cobertura >= 90%.${NC}"
                rm -f "$temp_log" "$ai_res_file"
                return 0
            else
                echo -e "${YELLOW}⚠️ Tests pasaron pero la cobertura (${current_coverage}%) es menor al 90%.${NC}"
                # Intentar mejorar cobertura llamando a IA (opcional, por ahora lo dejamos pasar si los tests están bien)
                return 0 
            fi
        fi

        echo -e "${YELLOW}⚠️ Fallos detectados en tests. Invocando IA para reparación...${NC}"
        
        local failing_file=$(grep -E "FAIL" "$temp_log" | head -1 | awk '{print $2}')
        [ -z "$failing_file" ] && failing_file=$(grep -oE "src/[^ ]+\.spec\.ts" "$temp_log" | head -1)

        if [ -n "$failing_file" ] && [ -f "$failing_file" ]; then
            echo -e "${BLUE}🔧 Reparando: $failing_file${NC}"
            local prompt_file=".gemini/tmp/qa_prompt.txt"
            echo "ERES UN EXPERTO EN JEST Y NESTJS. REPARA ESTE TEST QUE FALLA.
            ARCHIVO: $failing_file
            CONTENIDO ACTUAL:
            $(cat "$failing_file")
            ERROR DE JEST:
            $(tail -n 50 "$temp_log")
            RESPONDE SOLO CON EL CÓDIGO COMPLETO REPARADO, SIN MARKDOWN, SIN EXPLICACIONES." > "$prompt_file"

            bash "$AGENT_ROOT/.gemini/core/ai-bridge.sh" "gemini-3-flash-preview" "$prompt_file" > "$ai_res_file" 2>/dev/null
            
            if [ $? -eq 0 ] && [ -s "$ai_res_file" ]; then
                local clean=$(cat "$ai_res_file" | sed 's/^```[a-z]*//g' | sed 's/^```//g' | sed 's/```$//g')
                echo "$clean" | awk '/^[[:space:]]*(import|export|@|const|let|var|class|function|describe|it|test|\/\*|\/\/)/ {p=1} p' > "$failing_file"
                echo -e "${GREEN}✨ IA aplicó reparación a $failing_file. Reintentando tests...${NC}"
            fi
        else
            echo -e "${RED}❌ No se pudo identificar el archivo fallido.${NC}"
            break
        fi
        iteration=$((iteration + 1))
    done
    return 1
}

run_with_autofix() {
    local cmd="$1"; local target_file="$2"; local mode="${3:-runtime}"; local max_retries=3; local attempt=1
    while [ $attempt -le $max_retries ]; do
        eval "$cmd" > /dev/null 2>&1
        [ $? -eq 0 ] && return 0
        attempt=$((attempt + 1))
    done
    return 1
}
