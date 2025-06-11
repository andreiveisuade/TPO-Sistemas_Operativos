#!/bin/bash
# Script para realizar un escaneo de seguridad REMOTA del servidor objetivo.
# Realiza un análisis de puertos abiertos y servicios en ejecución en un servidor remoto.
#
# Requisitos:
# El comando nmap debe estar instalado previamente en el sistema

set -u

# --- Configuración inicial ---
MAQUINA_TARGET="$1"
FECHA_ESCANEO=$(date +"%Y%m%d_%H%M%S")
MAQUINA_EJECUTORA=$(hostname)

# Verificar que nmap esté instalado
if ! command -v nmap &> /dev/null; then
    echo "ERROR: nmap no está instalado. Por favor instálalo manualmente."
    exit 1
fi

echo "=== INICIANDO ESCANEO REMOTO DE SEGURIDAD ==="
echo "Objetivo de Escaneo: $MAQUINA_TARGET"
echo "Ejecutado desde: $MAQUINA_EJECUTORA"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "---------------------------------------------"

# --- Escaneo rápido de puertos ---
# Realiza un escaneo rápido de los 100 puertos TCP más comunes en el objetivo.
#   -F: Escaneo rápido (Fast) - Escanea solo los 100 puertos más comunes
echo -e "\n[+] Escaneo rápido de puertos TCP más comunes (-F)..."
nmap -F "$MAQUINA_TARGET" || echo "ERROR: Falló el escaneo -F"

# --- Escaneo detallado de servicios ---
# Realiza un escaneo más exhaustivo para detectar versiones de servicios en puertos abiertos.
#   -sV: Detección de versiones - Determina la versión de los servicios encontrados. De esta manera se puede identificar el tipo de servicio y su versión para actualizarlos y evitar vulnerabilidades.
#   Este escaneo es más lento pero proporciona información valiosa sobre los servicios
echo -e "\n[+] Detección de servicios y versiones en puertos abiertos (-sV)..."
nmap -sV "$MAQUINA_TARGET" || echo "ERROR: Falló el escaneo -sV"

echo -e "\n[+] Auditoría de red remota finalizada."
exit 0