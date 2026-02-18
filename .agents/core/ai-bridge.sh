#!/bin/bash

# .gemini/core/ai-bridge.sh
PROMPT_FILE_IN="$2"

# Jerarquía de modelos actualizada a Febrero 2026
# Intentamos primero con la Serie 3 (Preview) y bajamos a 2.5/1.5 si fallan
MODELS=(
    "gemini-3-flash-preview" 
    "gemini-3-pro-preview" 
    "gemini-2.5-flash" 
    "gemini-1.5-flash"
)

# Resolver rutas absolutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TMP_DIR="$AGENT_ROOT/.agents/tmp"

mkdir -p "$TMP_DIR"
PAYLOAD_FILE="$TMP_DIR/payload.json"

# --- VALIDACIÓN DE IDENTIDAD ---
if [ -z "$GEMINI_API_KEY" ]; then
    if ! command -v gemini >/dev/null 2>&1; then
        echo "❌ Error: No se encontró GEMINI_API_KEY ni el CLI de Gemini instalado." >&2
        echo "👉 Ejecuta: ./dev-agent.sh init" >&2
        exit 1
    fi
fi

cleanup() {
    rm -f "$PAYLOAD_FILE"
}
trap cleanup EXIT

for MODEL_NAME in "${MODELS[@]}"; do
    # 1. Intentar por API KEY (Modo Universal)
    if [ ! -z "$GEMINI_API_KEY" ]; then
        STRICT_PROMPT="SYSTEM: Eres un generador de CÓDIGO PURO. NO intentes usar herramientas. Solo devuelve el texto solicitado.\n\nUSER: $(cat "$PROMPT_FILE_IN")"
        
        if command -v python3 >/dev/null 2>&1; then
            ESCAPED_TEXT=$(python3 -c "import json, sys; print(json.dumps(sys.stdin.read()))" <<< "$STRICT_PROMPT")
        else
            ESCAPED_TEXT="\"$(echo "$STRICT_PROMPT" | sed 's/\\/\\\\/g;s/\"/\\\"/g;s/$/\\n/' | tr -d '\n')\""
        fi

        echo "{\"contents\": [{\"parts\":[{\"text\": $ESCAPED_TEXT}]}]}" > "$PAYLOAD_FILE"

        RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${GEMINI_API_KEY}" \
            -H "Content-Type: application/json" \
            -d @"$PAYLOAD_FILE")
        
        TEXT=$(echo "$RESPONSE" | grep -oE '"text": "[^"]+"' | head -1 | sed 's/"text": "//;s/"$//' | sed 's/\\n/\n/g' | sed 's/\\"/"/g')
        
        if [ ! -z "$TEXT" ]; then
            echo "$TEXT"
            exit 0
        fi
    fi

    # 2. Intentar por CLI
    if command -v gemini >/dev/null 2>&1; then
        # Intentar prompt con el modelo actual, si falla el loop continúa
        if TEXT=$(gemini prompt --model "$MODEL_NAME" < "$PROMPT_FILE_IN" 2>/dev/null); then
            echo "$TEXT" | grep -v "Loaded cached credentials"
            exit 0
        fi
    fi
    
    echo "⚠️ Falló intento con $MODEL_NAME, reintentando con siguiente modelo..." >&2
done

echo "❌ Error: No se pudo obtener respuesta de ningún modelo de IA." >&2
exit 1