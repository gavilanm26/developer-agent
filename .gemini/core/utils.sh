#!/bin/bash

# Determinar la ruta raíz del agente
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_ROOT="$(dirname "$(dirname "$UTILS_DIR")")"

# Función de timeout real para procesos y subprocesos
run_with_timeout() {
    local duration=$1; shift
    local cmd="$@"
    
    # Ejecutamos en segundo plano
    eval "$cmd" &
    local pid=$!
    
    local count=0
    while kill -0 $pid 2>/dev/null; do
        if [ $count -ge $duration ]; then
            echo "⏰ TIMEOUT ($duration s). Matando $pid..."
            kill -9 $pid 2>/dev/null
            return 124
        fi
        sleep 1; ((count++))
    done
    wait $pid
    return $?
}

# Función para obtener el porcentaje de cobertura total
get_coverage_pct() {
    local log_file=$1
    # Extrae el número de la columna % Stmts de la fila "All files"
    local pct=$(grep "All files" "$log_file" | awk '{print $4}' | cut -d. -f1 | tr -d '%')
    echo "${pct:-0}"
}

# Función para obtener archivos con baja cobertura o fallos en el reporte de Jest
get_problematic_files_with_details() {
    local log_file=$1
    # Extrae: Archivo | % Stmts | Líneas no cubiertas
    grep -E "\.ts[[:space:]]*|" "$log_file" | awk -F'|' '$2 !~ /100/ {print $1 ":" $2 "%:Lines:" $6}' | sed 's/[[:space:]]//g'
}

# --- UTILIDADES DE TEMPLATES ---
apply_global_templates() {
    local target_dir="$1"
    local global_tpl_dir="$AGENT_ROOT/.gemini/.templates/global"
    local BLUE='\033[0;34m'
    local NC='\033[0m'

    if [ -d "$global_tpl_dir" ] && [ "$(ls -A "$global_tpl_dir")" ]; then
        echo -e "${BLUE}🌍 Aplicando templates globales...${NC}"
        
        # Copiar contenido recursivamente
        cp -R "$global_tpl_dir/"* "$target_dir/" 2>/dev/null
        cp -R "$global_tpl_dir/."* "$target_dir/" 2>/dev/null
        
        # Renombrar recursivamente quitando .tpl (Generic Rename)
        # Ejemplo: Dockerfile.tpl -> Dockerfile, .env.tpl -> .env
        find "$target_dir" -name "*.tpl" -exec sh -c 'mv "$1" "${1%.tpl}"' _ {} \;
    fi
}

# --- GARANTE DE CALIDAD E INTEGRIDAD ---
ensure_quality_standards() {
    local test_cmd="npm run test:cov"
    local max_iterations=10
    local iteration=1
    # Rutas absolutas
    local temp_log="$AGENT_ROOT/.gemini/tmp/qa_report.log"
    local prompt_file="$AGENT_ROOT/.gemini/tmp/qa_prompt.txt"
    local ai_res_file="$AGENT_ROOT/.gemini/tmp/ai_res.txt"
    
    local modified_files=()
    local bugs_fixed=()
    local coverage_goal=95

    mkdir -p "$AGENT_ROOT/.gemini/tmp"
    while [ $iteration -le $max_iterations ]; do
        echo -e "\n🔍 Iteración $iteration/$max_iterations: Verificando Calidad Total..."
        run_with_timeout 180 "$test_cmd" > "$temp_log" 2>&1
        local exit_code=$?
        local current_coverage=$(get_coverage_pct "$temp_log")
        
        if [ $exit_code -eq 0 ] && [ "$current_coverage" -ge "$coverage_goal" ]; then
            echo -e "✅ CALIDAD TOTAL ALCANZADA: Tests OK y Cobertura al $current_coverage%."
            echo "📂 Archivos mejorados: ${modified_files[@]}"
            [ ${#bugs_fixed[@]} -gt 0 ] && echo "🐛 Bugs corregidos: ${bugs_fixed[@]}"
            
            # Limpieza de archivos temporales al éxito
            rm -f "$temp_log" "$prompt_file" "$ai_res_file"
            return 0
        fi

        local task_mode="FIX_FAIL"; [ $exit_code -eq 0 ] && task_mode="IMPROVE_COVERAGE"
        local targets=$(get_problematic_files_with_details "$temp_log")
        [ -z "$targets" ] && targets="General:0%:Lines:All"

        for target_info in $targets; do
            local file_name=$(echo $target_info | cut -d: -f1)
            local uncovered=$(echo $target_info | cut -d: -f4)
            local prod_file=$(find src -name "$(basename "$file_name")" | head -1)
            [ -z "$prod_file" ] || [ ! -f "$prod_file" ] && continue
            
            local spec_file="${prod_file%.ts}.spec.ts"
            [ ! -f "$spec_file" ] && spec_file=$(find src -name "$(basename "$spec_file")" | head -1)
            [ -z "$spec_file" ] || [ ! -f "$spec_file" ] && continue

            cat <<EOF > "$prompt_file"
ERES UN ARQUITECTO DE SOFTWARE SENIOR. 
TU MISIÓN ES REPARAR EL ARCHIVO PROPORCIONADO.

REGLAS CRÍTICAS:
1. RESPONDE ÚNICAMENTE CON EL CÓDIGO FUENTE.
2. NO EXPLIQUES NADA. NO SALUDES. NO DES CONTEXTO.
3. SI INCLUYES TEXTO HUMANO, EL SERVIDOR MORIRÁ.
4. SIN COMENTARIOS. SIN BLOQUES MARKDOWN.

ARCHIVO A EDITAR: $repair_target
CONTENIDO: $(cat "$repair_target")
ERROR: $(tail -n 50 "$temp_log")
EOF

            # --- LLAMADA A IA (ORDEN SOLICITADO ENERO 2026) ---
            local ia_success=false
            local models=("gemini-3-flash-preview" "gemini-3-pro-preview" "gemini-2.5-pro" "gemini-2.5-flash")
            
            for model in "${models[@]}"; do
                echo "📡 Invocando IA ($model)..."
                run_with_timeout 60 "$AGENT_ROOT/.gemini/core/ai-bridge.sh" "$model" "$prompt_file" > "$ai_res_file" 2>/dev/null
                if [ $? -eq 0 ] && [ -s "$ai_res_file" ]; then
                    local clean=$(cat "$ai_res_file" | sed 's/^```[a-z]*//g' | sed 's/^```//g' | sed 's/```$//g')
                    # Filtro de basura para tests
                    echo "$clean" | awk '/^[[:space:]]*(import|export|@|const|let|var|class|function|describe|it|test|\/\*|\/\/)/ {p=1} p' > "$spec_file"
                    
                    if [ ! -s "$spec_file" ]; then
                        echo "$clean" > "$spec_file"
                    fi
                    
                    modified_files+=($(basename "$spec_file")); ia_success=true; echo "✅ OK."; break
                fi
            done

            # Fallback a ChatGPT si Gemini falla
            if [ "$ia_success" = false ] && command -v codex >/dev/null 2>&1; then
                echo "🔄 Fallback a ChatGPT..."
                run_with_timeout 60 "codex exec --dangerously-bypass-approvals-and-sandbox \"$(cat "$prompt_file")\"" > "$ai_res_file" 2>/dev/null
                if [ $? -eq 0 ] && [ -s "$ai_res_file" ]; then
                    local clean=$(cat "$ai_res_file" | sed 's/^```[a-z]*//g' | sed 's/^```//g' | sed 's/```$//g')
                    echo "$clean" > "$spec_file"; modified_files+=($(basename "$spec_file")); ia_success=true; echo "✅ OK."
                fi
            fi
        done
        iteration=$((iteration + 1))
    done
    return 1
}

# run_with_autofix para runtime y errores rápidos
run_with_autofix() {
    local cmd="$1"; local target_file="$2"; local mode="${3:-runtime}"; local max_retries=3; local attempt=1
    
    # Rutas absolutas
    local error_log="$AGENT_ROOT/.gemini/tmp/error.log"
    local autofix_prompt_file="$AGENT_ROOT/.gemini/tmp/autofix_prompt.txt"
    local ai_res_file="$AGENT_ROOT/.gemini/tmp/ai_res.txt"

    mkdir -p "$AGENT_ROOT/.gemini/tmp"
    while [ $attempt -le $max_retries ]; do
        echo "🔄 Intento $attempt: Verificando $mode..."
        run_with_timeout 120 "eval $cmd" > "$error_log" 2>&1
        local status=$?
        
        if [ $status -eq 0 ] || [ $status -eq 124 ]; then
            # Limpieza tras éxito
            rm -f "$error_log" "$autofix_prompt_file" "$ai_res_file"
            return 0
        fi
        
        echo "❌ Fallo en $mode. Invocando IA para reparar $target_file..."
        # Guardar prompt en archivo temporal
        echo "Repara el archivo $(cat "$target_file") basándose en este error: $(tail -n 20 "$error_log"). Devuelve solo el código completo corregido, sin comentarios, sin markdown." > "$autofix_prompt_file"
        
        # Invocamos el puente pasándole la RUTA del archivo
        run_with_timeout 60 "$AGENT_ROOT/.gemini/core/ai-bridge.sh" "gemini-3-flash-preview" "$autofix_prompt_file" > "$ai_res_file" 2>/dev/null
        
        if [ $? -eq 0 ] && [ -s "$ai_res_file" ]; then
            # Limpieza segura y robusta:
            # 1. Quitamos bloques markdown
            local clean=$(cat "$ai_res_file" | sed 's/^```[a-z]*//g' | sed 's/^```//g' | sed 's/```$//g')
            
            # 2. Filtro de basura: Buscamos la primera linea que sea codigo real 
            # (import, export, @decorator, const, class, etc) y borramos lo anterior.
            echo "$clean" | awk '/^[[:space:]]*(import|export|@|const|let|var|class|function|\/\*|\/\/)/ {p=1} p' > "$target_file"
            
            # 3. Verificar si el archivo quedo vacio tras el filtro (por si la IA no uso esas palabras)
            if [ ! -s "$target_file" ]; then
                echo "$clean" > "$target_file"
            fi
            
            echo "✨ IA aplicó reparación limpia. Reintentando..."
        else
            echo "⚠️ IA no pudo generar una respuesta válida."
        fi
        attempt=$((attempt + 1))
    done
    return 1
}
