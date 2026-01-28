#!/bin/bash

# Determinar la ruta raíz del agente
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_ROOT="$(dirname "$(dirname "$UTILS_DIR")")"

# Función de timeout real para procesos y subprocesos
run_with_timeout() {
    local duration=$1; shift
    ( eval "$@" ) &
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

get_coverage_pct() {
    local log_file=$1
    local pct=$(grep "All files" "$log_file" | awk '{print $4}' | cut -d. -f1 | tr -d '%')
    echo "${pct:-0}"
}

get_problematic_files_with_details() {
    local log_file=$1
    # Extrae: Archivo | % Stmts | Líneas no cubiertas
    grep -E "\.ts[[:space:]]*|" "$log_file" | awk -F'|' '$2 !~ /100/ {print $1 ":" $2 "%:Lines:" $6}' | sed 's/[[:space:]]//g'
}

# --- GARANTE DE CALIDAD E INTEGRIDAD ---
ensure_quality_standards() {
    local test_cmd="npm run test:cov"
    local max_iterations=10
    local iteration=1
    local temp_log=".gemini/tmp/qa_report.log"
    local prompt_file=".gemini/tmp/qa_prompt.txt"
    local modified_files=()
    local bugs_fixed=()
    local coverage_goal=95

    mkdir -p .gemini/tmp
    while [ $iteration -le $max_iterations ]; do
        echo -e "\n🔍 Iteración $iteration/$max_iterations: Verificando Calidad Total..."
        run_with_timeout 180 "$test_cmd" > "$temp_log" 2>&1
        local exit_code=$?
        local current_coverage=$(get_coverage_pct "$temp_log")
        
        if [ $exit_code -eq 0 ] && [ "$current_coverage" -ge "$coverage_goal" ]; then
            echo -e "✅ CALIDAD TOTAL ALCANZADA: Tests OK y Cobertura al $current_coverage%."
            echo "📂 Archivos mejorados: ${modified_files[@]}"
            [ ${#bugs_fixed[@]} -gt 0 ] && echo "🐛 Bugs corregidos: ${bugs_fixed[@]}"
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

            echo "🤖 Procesando: $(basename "$spec_file") (Modo: $task_mode)"
            
            # --- CONSTRUIR PROMPT ---
            if [ "$task_mode" = "FIX_FAIL" ]; then
                cat <<EOF > "$prompt_file"
ERES UN ARQUITECTO SENIOR. Repara los fallos garantizando funcionalidad.
1. Si es error de test, arregla $spec_file.
2. Si es un BUG REAL, arregla la lógica en $prod_file.
REGLAS: Sin comentarios. Código completo.
ARCHIVO PROD: $(cat "$prod_file")
ARCHIVO TEST: $(cat "$spec_file")
ERROR: $(tail -n 50 "$temp_log")
EOF
            else
                cat <<EOF > "$prompt_file"
ERES UN SENIOR QA. Sube cobertura de $prod_file al 100% mejorando $spec_file.
INSTRUCCIÓN: Solo modifica el test. Cubre líneas: $uncovered.
REGLAS: Sin comentarios. Mocks de NestJS. Código completo.
ARCHIVO PROD: $(cat "$prod_file")
ARCHIVO TEST: $(cat "$spec_file")
EOF
            fi

            # --- LLAMADA A IA (ORDEN SOLICITADO ENERO 2026) ---
            local ia_success=false
            local models=("gemini-3-flash-preview" "gemini-3-pro-preview" "gemini-2.5-pro" "gemini-2.5-flash")
            
            for model in "${models[@]}"; do
                echo "📡 Invocando Gemini ($model)..."
                run_with_timeout 60 "gemini prompt --model \"$model\" \"$(cat "$prompt_file")\"" > .gemini/tmp/ai_res.txt 2>/dev/null
                if [ $? -eq 0 ] && [ -s .gemini/tmp/ai_res.txt ]; then
                    local clean=$(cat .gemini/tmp/ai_res.txt | sed 's/^```[a-z]*//g' | sed 's/^```//g' | sed 's/```$//g')
                    if [ "$task_mode" = "FIX_FAIL" ] && echo "$clean" | grep -q "class.*Adapter\|class.*Service"; then
                        echo "$clean" > "$prod_file"; bugs_fixed+=($(basename "$prod_file"))
                    else
                        echo "$clean" > "$spec_file"
                    fi
                    modified_files+=($(basename "$spec_file")); ia_success=true; echo "✅ OK."; break
                fi
            done

            # Fallback a ChatGPT si Gemini falla
            if [ "$ia_success" = false ] && command -v codex >/dev/null 2>&1; then
                echo "🔄 Fallback a ChatGPT..."
                run_with_timeout 60 "codex exec --dangerously-bypass-approvals-and-sandbox \"$(cat "$prompt_file")\"" > .gemini/tmp/ai_res.txt 2>/dev/null
                if [ $? -eq 0 ] && [ -s .gemini/tmp/ai_res.txt ]; then
                    local clean=$(cat .gemini/tmp/ai_res.txt | sed 's/^```[a-z]*//g' | sed 's/^```//g' | sed 's/```$//g')
                    echo "$clean" > "$spec_file"; modified_files+=($(basename "$spec_file")); ia_success=true; echo "✅ OK."
                fi
            fi
        done
        iteration=$((iteration + 1))
    done
    return 1
}

# run_with_autofix para compilación y runtime
run_with_autofix() {
    local cmd="$1"; local target="$2"; local mode="${3:-build}"; local max=3; local attempt=1
    mkdir -p .gemini/tmp
    while [ $attempt -le $max ]; do
        echo "🔄 Verificando $mode (Intento $attempt)..."
        run_with_timeout 120 "$cmd" > .gemini/tmp/error.log 2>&1
        [ $? -eq 0 ] && return 0
        echo "❌ Fallo. Invocando IA..."
        local prompt="Repara $(cat "$target") basado en $(tail -n 20 .gemini/tmp/error.log). SOLO CODIGO. SIN COMENTARIOS."
        # Intentar Gemini 3 Flash Preview (prioridad rapidez)
        run_with_timeout 60 "gemini prompt --model \"gemini-3-flash-preview\" \"$prompt\"" > .gemini/tmp/ai_res.txt 2>/dev/null
        if [ $? -eq 0 ] && [ -s .gemini/tmp/ai_res.txt ]; then
            cat .gemini/tmp/ai_res.txt | sed 's/^```[a-z]*//g' | sed 's/^```//g' | sed 's/```$//g' > "$target"
            echo "✨ Reparado."; attempt=$((attempt + 1)); continue
        fi
        attempt=$((attempt + 1))
    done
    return 1
}
