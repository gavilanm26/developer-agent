#!/bin/bash

# --- Configuración de Rutas (Absolutas para Portabilidad) ---
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$INSTALL_DIR/.gemini"
ACTIONS_DIR="$AGENT_DIR/actions"

# Colores
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Cargar variables de entorno desde el directorio de instalación
if [ -f "$INSTALL_DIR/.env" ]; then
    export $(grep -v '^#' "$INSTALL_DIR/.env" | xargs)
fi

# Asegurar permisos de ejecución en las acciones
chmod +x "$ACTIONS_DIR"/*.sh 2>/dev/null

check_environment() {
    # Si hay API KEY, el entorno es válido
    if [ ! -z "$GEMINI_API_KEY" ]; then
        return 0
    fi

    # Si no hay Key, verificar si el CLI está instalado
    if ! command -v gemini >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: No se detectó GEMINI_API_KEY ni Gemini CLI instalado.${NC}"
        echo -e "Corre ${YELLOW}./dev-agent.sh init${NC} para configurar el entorno."
        exit 1
    fi
}

setup_agent() {
    echo -e "${BLUE}⚙️ Iniciando configuración del Agente...${NC}"
    
    echo -e "\n¿Cómo deseas conectar el Agente?"
    echo "1) Usar GEMINI_API_KEY (Recomendado para CI/CD)"
    echo "2) Usar Inicio de Sesión en Navegador (Gemini CLI)"
    read -p "Opción (1-2): " AUTH_OPT

    if [ "$AUTH_OPT" == "1" ]; then
        read -p "Pega tu GEMINI_API_KEY: " USER_KEY
        echo "GEMINI_API_KEY=$USER_KEY" >> "$INSTALL_DIR/.env"
        echo -e "${GREEN}✅ Key guardada en .env${NC}"
    else
        if ! command -v npm >/dev/null 2>&1; then
            echo -e "${RED}❌ Error: Necesitas Node.js instalado.${NC}"
            exit 1
        fi
        if ! command -v gemini >/dev/null 2>&1; then
            npm install -g @google/gemini-cli
        fi
        gemini login
    fi
    echo -e "${GREEN}✅ Agente configurado.${NC}"
}

show_help() {
    echo -e "${BLUE}Developer Agent CLI${NC}"
    echo "Comandos:"
    echo "  init          Configura el entorno"
    echo "  new-service   Crea un nuevo microservicio o gateway"
    echo "  new-endpoint  Crea un endpoint en un API Gateway"
    echo "  new-module    Crea un módulo en un microservicio"
    echo "  help          Ayuda"
}

case "$1" in
    init)
        setup_agent
        ;; 
    new-service)
        check_environment
        echo -e "${YELLOW}>>> Iniciando Generación de Servicio${NC}"
        
        echo -e "\nSelecciona el lenguaje:"
        echo "1) NestJS (TypeScript - Hexagonal)"
        echo "2) Java (Spring Boot)"
        echo "3) Python (FastAPI)"
        read -p "Opción (1-3): " LANG_OPT

        case "$LANG_OPT" in
            1) LANG="nestjs" ;; 
            2) LANG="java" ;; 
            3) LANG="python" ;; 
            *) echo -e "${RED}Opción inválida.${NC}"; exit 1 ;; 
        esac
        
        if [ "$LANG" == "nestjs" ]; then
            echo -e "\nSelecciona el tipo de template:"
            echo "1) Microservicio Estándar (Hexagonal)"
            echo "2) API Gateway (Base)"
            echo "3) Servicio con Auth (Próximamente)"
            echo "4) Otro / Limpio"
            read -p "Opción (1-4): " TYPE_OPT

            case "$TYPE_OPT" in
                1)
                    bash "$ACTIONS_DIR/create-service-nestjs.sh"
                    ;; 
                2)
                    echo -e "\nTipo de API Gateway:"
                    echo "1) Solo REST (Ligero)"
                    echo "2) Híbrido (REST + GraphQL)"
                    read -p "Opción (1-2): " GW_TYPE_OPT
                    
                    if [ "$GW_TYPE_OPT" == "1" ]; then
                        bash "$ACTIONS_DIR/create-gateway.sh" "" "rest"
                    else
                        bash "$ACTIONS_DIR/create-gateway.sh" "" "hybrid"
                    fi
                    ;; 
                *)
                    bash "$ACTIONS_DIR/create-service-nestjs.sh"
                    ;; 
            esac
        else
            echo -e "${RED}Lenguaje no soportado actualmente.${NC}"
        fi
        ;; 

    new-endpoint)
        bash "$ACTIONS_DIR/create-gateway-endpoint.sh" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
        ;; 

    new-module)
        bash "$ACTIONS_DIR/create-module-nestjs.sh" "$2"
        ;; 

    help|*)
        show_help
        ;; 
esac