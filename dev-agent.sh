#!/bin/bash

# --- Configuración ---
AGENT_DIR=".gemini"
ACTIONS_DIR="$AGENT_DIR/actions"

# Colores
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

chmod +x $ACTIONS_DIR/*.sh 2>/dev/null

check_environment() {
    if ! command -v gemini >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Gemini CLI no está instalado.${NC}"
        echo -e "Corre ${YELLOW}./dev-agent.sh init${NC} para configurar el entorno."
        exit 1
    fi
}

setup_agent() {
    echo -e "${BLUE}⚙️ Iniciando configuración del Agente...${NC}"
    
    # 1. Instalar Gemini CLI si falta
    if ! command -v gemini >/dev/null 2>&1; then
        echo "Instalando Gemini CLI globalmente..."
        npm install -g @google/gemini-cli
    fi

    # 2. Verificar sesión
    echo -e "${YELLOW}Verificando sesión de Gemini...${NC}"
    if ! gemini prompt "test" --model "gemini-3-flash-preview" >/dev/null 2>&1; then
        echo "Por favor, inicia sesión en Gemini (se abrirá tu navegador):"
        gemini login
    fi

    echo -e "${GREEN}✅ Agente configurado y listo para trabajar.${NC}"
}

show_help() {
    echo -e "${BLUE}Developer Agent CLI${NC}"
    echo "Comandos:"
    echo "  init          Configura el entorno (CLI, Login, etc.)"
    echo "  new-service   Inicia un nuevo microservicio o gateway"
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
        read -p "Lenguaje (nestjs/java/python): " LANG
        
        if [ "$LANG" == "nestjs" ]; then
            echo -e "\nSelecciona el tipo de template:"
            echo "1) Microservicio Estándar (Hexagonal)"
            echo "2) API Gateway (Base)"
            echo "3) Servicio con Auth (Próximamente)"
            echo "4) Otro / Limpio"
            read -p "Opción (1-4): " TYPE_OPT

            case "$TYPE_OPT" in
                1)
                    ./$ACTIONS_DIR/create-service-nestjs.sh
                    ;; 
                2)
                    ./$ACTIONS_DIR/create-gateway.sh
                    ;; 
                *)
                    ./$ACTIONS_DIR/create-service-nestjs.sh # Fallback al estándar por ahora
                    ;; 
            esac
        else
            echo -e "${RED}Lenguaje no soportado actualmente.${NC}"
        fi
        ;; 

    new-endpoint)
        ./$ACTIONS_DIR/create-gateway-endpoint.sh "$2" "$3" "$4" "$5" "$6" "$7" "$8"
        ;; 

    new-module)
        ./$ACTIONS_DIR/create-module-nestjs.sh "$2"
        ;; 

    help|*)
        show_help
        ;; 
esac
