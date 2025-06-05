#!/bin/bash

# Detectar automáticamente el gestor de paquetes
detectar_gestor_paquetes() {
    if command -v dnf &>/dev/null; then
        echo "dnf install -y"
    elif command -v yum &>/dev/null; then
        echo "yum install -y"
    elif command -v apt &>/dev/null; then
        echo "apt install -y"
    elif command -v pacman &>/dev/null; then
        echo "pacman -Sy --noconfirm"
    else
        echo ""
    fi
}

# Verifica si un comando existe, y si no, intenta instalar el paquete
# Uso: asegurar_comando nombre_comando [nombre_paquete]
asegurar_comando() {
    local comando="$1"
    local paquete="${2:-$1}"  # Usa el mismo nombre si no se especifica

    if ! command -v "$comando" &>/dev/null; then
        echo "🔍 $comando no está instalado. Intentando instalar..."
        local instalador=$(detectar_gestor_paquetes)
        if [ -n "$instalador" ]; then
            echo "💡 Ejecutando: sudo $instalador $paquete"
            sudo $instalador "$paquete" || {
                echo "❌ Falló la instalación de $paquete"
                exit 1
            }
        else
            echo "❌ No se pudo detectar un gestor de paquetes válido."
            exit 1
        fi
    else
        echo "✅ $comando ya está instalado."
    fi
}