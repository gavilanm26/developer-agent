#!/bin/bash
# .gemini/actions/create-service-nestjs.sh

NAME=$1
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$NAME" ]; then
    read -p "Nombre del servicio (kebab-case): " NAME
fi

echo -e "${BLUE}Iniciando NestJS CLI para crear '$NAME'...${NC}"

# Validar si nest está instalado
if command -v nest >/dev/null 2>&1; then
    NEST_CMD="nest"
else
    NEST_CMD="npx @nestjs/cli"
fi

$NEST_CMD new "$NAME" --strict --skip-git --package-manager npm

if [ $? -ne 0 ]; then
    echo -e "${RED}✘ Error al crear el proyecto con NestJS CLI.${NC}"
    exit 1
fi

echo -e "${BLUE}Limpiando boilerplate y configurando entorno...${NC}"
TARGET_SRC="$NAME/src"

# 1. Eliminar archivos innecesarios
rm -f "$TARGET_SRC/app.controller.ts" "$TARGET_SRC/app.service.ts" "$TARGET_SRC/app.controller.spec.ts"

# 2. Limpiar app.module.ts
cat <<EOF > "$TARGET_SRC/app.module.ts"
import { Module } from '@nestjs/common';

@Module({
  imports: [],
  controllers: [],
  providers: [],
})
export class AppModule {}
EOF

# 3. Crear .gitignore
cat <<EOF > "$NAME/.gitignore"
# compiled output
/dist
/node_modules
/build

# Logs
logs
*.log
npm-debug.log*
pnpm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# OS
.DS_Store

# Tests
/coverage
/.nyc_output

# IDEs and editors
/.idea
.project
.classpath
.c9/
*.launch
.settings/
*.sublime-workspace

# IDE - VSCode
.vscode/
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# dotenv environment variable files
.env
.env.development.local
.env.test.local
.env.production.local
.env.local

# temp directory
.temp
.tmp

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Diagnostic reports (https://nodejs.org/api/report.html)
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Developer Agent (Private)
AGENT.md
dev-agent.sh
.gemini/

EOF

# 4. Lógica condicional 'auth'
if [[ "$NAME" == *"auth"* ]]; then
    echo -e "${YELLOW}Detectado servicio de autenticación. Creando módulo 'auth'...${NC}"
    cd "$NAME"
    $NEST_CMD g mo auth
    mkdir -p "src/auth"/{application/service,domain/{interfaces,ports},infrastructure/{controller,repository/helpers,adapter,dto}}
    cd ..
fi

echo -e "${GREEN}✔ Microservicio '$NAME' listo.${NC}"
