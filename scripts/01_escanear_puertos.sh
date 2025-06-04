#!/bin/bash
# Script de escaneo de puertos locales
# Realiza un escaneo completo de todos los puertos en localhost (1-65535)
# Utiliza la herramienta nmap para el escaneo

# Configuración de seguridad: sale si hay variables sin inicializar
set -u

# Mostrar información del escaneo
echo "=== ESCANEO DE PUERTOS LOCALES ==="
echo "Objetivo: localhost (esta máquina)"

# Verifica si nmap está instalado en el sistema
# nmap es una herramienta de código abierto para exploración de red y auditoría de seguridad
if ! command -v nmap &> /dev/null; then
    # Si nmap no está instalado, intenta instalarlo automáticamente
    echo "nmap no está instalado. Intentando instalar..."
    
    # Detecta el gestor de paquetes del sistema
    if command -v dnf &> /dev/null; then
        # Para sistemas basados en RedHat/Fedora/CentOS
        sudo dnf install -y nmap
    elif command -v apt-get &> /dev/null; then
        # Para sistemas basados en Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y nmap
    else
        echo "ERROR: No se pudo determinar el gestor de paquetes del sistema."
        echo "Por favor, instala nmap manualmente e intenta nuevamente."
        exit 1
    fi
    
    # Verifica si la instalación fue exitosa
    if ! command -v nmap &> /dev/null; then
        echo "ERROR: No se pudo instalar nmap automáticamente."
        echo "Por favor, instala nmap manualmente con el comando apropiado para tu distribución."
        exit 1
    fi
    
    echo "nmap instalado correctamente."
fi

# Muestra el comando que se va a ejecutar
echo ""
echo "Iniciando escaneo completo de puertos locales (1-65535)..."
echo "Este proceso puede tardar varios minutos..."

# Escaneo y guardado en variable de entorno
echo "Puertos abiertos detectados:"
PUERTOS_ABIERTOS=$(sudo nmap -sT -p- localhost | grep '^[0-9]' | cut -d'/' -f1 | tr '\n' ' ')

echo "$PUERTOS_ABIERTOS"
echo ""

export PUERTOS_ABIERTOS