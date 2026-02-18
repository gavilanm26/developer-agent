#!/bin/bash
# .gemini/actions/create-module-nestjs.sh

NAME=$1
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$NAME" ]; then
    read -p "Nombre del módulo (kebab-case): " NAME
fi

if [ ! -d "src" ]; then
    echo -e "${RED}✘ Error: Ejecuta este comando en la raíz de tu microservicio (donde está la carpeta src/).${NC}"
    exit 1
fi

if command -v nest >/dev/null 2>&1; then
    NEST_CMD="nest"
else
    NEST_CMD="npx @nestjs/cli"
fi

echo -e "${BLUE}Ejecutando '$NEST_CMD g mo $NAME'...${NC}"
$NEST_CMD g mo "$NAME"

if [ $? -eq 0 ]; then
    TARGET_DIR="src/$NAME"
    echo -e "${BLUE}Inyectando estructura hexagonal en $TARGET_DIR...${NC}"
    mkdir -p "$TARGET_DIR"/{application/service,domain/{interfaces,ports},infrastructure/{controller,repository/helpers,adapter,dto}}
    echo -e "${GREEN}✔ Módulo '$NAME' creado y registrado.${NC}"
else
    echo -e "${RED}✘ Error al crear el módulo.${NC}"
    exit 1
fi
