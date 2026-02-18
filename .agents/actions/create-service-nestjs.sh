#!/bin/bash
# .agents/actions/create-service-nestjs.sh

# Configurar rutas absolutas AL INICIO para evitar errores con cd
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_AGENT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

NAME=$1
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$NAME" ]; then
    CURRENT_FOLDER=$(basename "$PWD")
    read -p "Nombre del servicio [$CURRENT_FOLDER]: " INPUT_NAME
    NAME="${INPUT_NAME:-$CURRENT_FOLDER}"
fi

echo -e "${BLUE}Iniciando generación de '$NAME'...${NC}"

# Validar y crear directorio si es necesario
CURRENT_DIR=$(basename "$PWD")
if [ "$CURRENT_DIR" != "$NAME" ]; then
    if [ -d "$NAME" ]; then
        echo -e "${YELLOW}El directorio '$NAME' ya existe.${NC}"
        read -p "¿Deseas entrar y continuar? (s/n): " CONFIRM
        if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
            exit 1
        fi
    else
        echo -e "${BLUE}Creando directorio '$NAME'...${NC}"
        mkdir -p "$NAME"
    fi
    cd "$NAME" || exit 1
fi

echo -e "${BLUE}Trabajando en $(pwd)...${NC}"

# Validar si nest está instalado
if command -v nest >/dev/null 2>&1; then
    NEST_CMD="nest"
else
    NEST_CMD="npx @nestjs/cli"
fi

# 1. Crear en carpeta temporal para evitar bloqueo de "Directorio no vacío"
TEMP_DIR="temp_nest_scaffold"
rm -rf "$TEMP_DIR"

echo -e "${BLUE}Generando estructura base...${NC}"
$NEST_CMD new "$TEMP_DIR" --strict --skip-git --package-manager npm >/dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}✘ Error al crear el proyecto base.${NC}"
    exit 1
fi

# 2. Mover archivos a la raíz
echo -e "${BLUE}Aplicando estructura al repositorio...${NC}"
# Copiar archivos ocultos y normales
cp -R "$TEMP_DIR/"* . 2>/dev/null
cp -R "$TEMP_DIR/."* . 2>/dev/null
rm -rf "$TEMP_DIR"

# 3. Actualizar nombre en package.json
sed -i '' "s/\"name\": \"$TEMP_DIR\"/\"name\": \"$NAME\"/" package.json 2>/dev/null || sed -i "s/\"name\": \"$TEMP_DIR\"/\"name\": \"$NAME\"/" package.json

echo -e "${BLUE}Limpiando boilerplate y configurando entorno...${NC}"
TARGET_SRC="src"

# 4. Eliminar archivos innecesarios
rm -f "$TARGET_SRC/app.controller.ts" "$TARGET_SRC/app.service.ts" "$TARGET_SRC/app.controller.spec.ts"

# 5. Limpiar app.module.ts
cat <<EOF > "$TARGET_SRC/app.module.ts"
import { Module } from '@nestjs/common';

@Module({
  imports: [],
  controllers: [],
  providers: [],
})
export class AppModule {}
EOF

# 6. Configurar .gitignore (Fusionando reglas del agente)
cat <<EOF >> ".gitignore"

# Developer Agent (Private)
AGENT.md
dev-agent.sh
.agents/
EOF

# 7. Lógica condicional 'auth'
# (Rutas ya calculadas al inicio)

# Importar utilidades
if [ -f "$ROOT_AGENT_DIR/.agents/core/utils.sh" ]; then
    source "$ROOT_AGENT_DIR/.agents/core/utils.sh"
fi

if [[ "$NAME" == *"auth"* ]]; then
    echo -e "${YELLOW}Detectado servicio de autenticación. Creando módulo 'auth'...${NC}"
    $NEST_CMD g mo auth
    mkdir -p "src/auth"/{application/service,domain/{interfaces,ports},infrastructure/{controller,repository/helpers,adapter,dto}}
fi

# Aplicar Templates Globales
if type apply_global_templates >/dev/null 2>&1; then
    apply_global_templates "."
fi

# 8. Implantar Cerebro del Agente (Self-Replication from .agents)
echo -e "${BLUE}🧠 Implantando identidad y reglas del Agente desde .agents...${NC}"
mkdir -p ".agents"

# Copiar identidad
if [ -f "$ROOT_AGENT_DIR/AGENT.md" ]; then
    cp "$ROOT_AGENT_DIR/AGENT.md" .
    echo -e "${GREEN}  - Identidad copiada a la raíz.${NC}"
fi

# Copiar reglas
if [ -d "$ROOT_AGENT_DIR/.agents/rules" ]; then
    cp -r "$ROOT_AGENT_DIR/.agents/rules" ".agents/"
    echo -e "${GREEN}  - Reglas Hexagonales copiadas.${NC}"
fi

# Copiar skills (opcional pero recomendado)
if [ -d "$ROOT_AGENT_DIR/.agents/skills" ]; then
    cp -r "$ROOT_AGENT_DIR/.agents/skills" ".agents/"
    echo -e "${GREEN}  - Skills copiadas.${NC}"
fi

# Copiar cerebros (grafos de decisión)
if [ -d "$ROOT_AGENT_DIR/.agents/brains" ]; then
    cp -r "$ROOT_AGENT_DIR/.agents/brains" ".agents/"
    echo -e "${GREEN}  - Grafos de decisión (Brains) copiados.${NC}"
fi

# Copiar workflows
if [ -d "$ROOT_AGENT_DIR/.agents/workflows" ]; then
    cp -r "$ROOT_AGENT_DIR/.agents/workflows" ".agents/"
    echo -e "${GREEN}  - Workflows copiados.${NC}"
fi

echo -e "${GREEN}✔ Microservicio '$NAME' listo en la raíz con cerebro implantado.${NC}"
