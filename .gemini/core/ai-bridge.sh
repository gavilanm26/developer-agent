#!/bin/bash

# .gemini/core/ai-bridge.sh
MODEL_NAME="${1:-gemini-3-flash-preview}"
PROMPT_FILE_IN="$2"

TMP_DIR=".gemini/tmp"
mkdir -p "$TMP_DIR"
PAYLOAD_FILE="$TMP_DIR/payload.json"

# 1. Intentar por API KEY (Modo Universal)
if [ ! -z "$GEMINI_API_KEY" ]; then
    if command -v python3 >/dev/null 2>&1; then
        ESCAPED_TEXT=$(python3 -c "import json, sys; print(json.dumps(open('$PROMPT_FILE_IN').read()))")
    else
        ESCAPED_TEXT="$(sed 's/\\/\\\\/g;s/"/\\"/g;s/$/\\n/' "$PROMPT_FILE_IN" | tr -d '\n')"
    fi

    echo "{\"contents\": [{\"parts\":[{\"text\": $ESCAPED_TEXT}]}]}" > "$PAYLOAD_FILE"

    # Llamada a la API
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

echo "❌ Error: No se detectó GEMINI_API_KEY ni el CLI de Gemini instalado." >&2
exit 1
