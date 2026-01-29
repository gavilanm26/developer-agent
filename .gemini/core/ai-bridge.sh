#!/bin/bash

# .gemini/core/ai-bridge.sh
MODEL_NAME="${1:-gemini-3-flash-preview}"
PROMPT_FILE_IN="$2"

# Resolver rutas absolutas para evitar nesting (.gemini/.gemini)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TMP_DIR="$AGENT_ROOT/.gemini/tmp"

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

# Cleanup function
cleanup() {
    rm -f "$PAYLOAD_FILE"
}
trap cleanup EXIT

# 1. Intentar por API KEY (Modo Universal)
if [ ! -z "$GEMINI_API_KEY" ]; then
    # Crear el JSON final con instrucción de no usar herramientas
    STRICT_PROMPT="SYSTEM: Eres un generador de CÓDIGO PURO. NO intentes usar herramientas, funciones o comandos (NO write_file, NO run_command). Solo devuelve el texto solicitado.\n\nUSER: $(cat "$PROMPT_FILE_IN")"
    
    if command -v python3 >/dev/null 2>&1; then
        ESCAPED_TEXT=$(python3 -c "import json, sys; print(json.dumps(sys.stdin.read()))" <<< "$STRICT_PROMPT")
    else
        ESCAPED_TEXT="\"$(echo "$STRICT_PROMPT" | sed 's/\\/\\\\/g;s/\"/\\\"/g;s/$/\\n/' | tr -d '\n')\""
    fi

    echo "{\"contents\": [{\"parts\":[{\"text\": $ESCAPED_TEXT}]}]}" > "$PAYLOAD_FILE"

    RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" \
        -d @"$PAYLOAD_FILE")
    
    # Sincronización
    sleep 0.5

    TEXT=$(echo "$RESPONSE" | grep -oE '"text": "[^"]+"' | head -1 | sed 's/"text": "//;s/"$//' | sed 's/\\n/\n/g' | sed 's/\\"/"/g')
    
    if [ ! -z "$TEXT" ]; then
        echo "$TEXT"
        exit 0
    else
        echo "❌ Error API Gemini (API KEY):" >&2
        echo "$RESPONSE" | grep -E 'message|status' | sed 's/^[[:space:]]*//' >&2
        exit 1
    fi
fi

# 2. Intentar por CLI (Sesión navegador)
if command -v gemini >/dev/null 2>&1; then
    # Usar redirección de entrada y filtrar el banner de credenciales
    gemini prompt --model "$MODEL_NAME" < "$PROMPT_FILE_IN" | grep -v "Loaded cached credentials"
    exit 0
fi

echo "❌ Error: Identidad no establecida." >&2
exit 1