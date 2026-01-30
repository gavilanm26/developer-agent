#!/bin/bash
# .gemini/actions/create-service-nestjs.sh

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

echo -e "${BLUE}Iniciando generación de '$NAME' en el directorio actual...${NC}"

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
.gemini/
EOF

# 7. Lógica condicional 'auth'
if [[ "$NAME" == *"auth"* ]]; then
    echo -e "${YELLOW}Detectado servicio de autenticación. Creando módulo 'auth'...${NC}"
    $NEST_CMD g mo auth
    mkdir -p "src/auth"/{application/service,domain/{interfaces,ports},infrastructure/{controller,repository/helpers,adapter,dto}}
fi

echo -e "${GREEN}✔ Microservicio '$NAME' listo en la raíz.${NC}"
