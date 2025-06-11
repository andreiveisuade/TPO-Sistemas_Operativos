#!/bin/bash
# Script para realizar un escaneo de seguridad REMOTA del servidor objetivo.
# Realiza un análisis de puertos abiertos y servicios en ejecución en un servidor remoto.
#
# Requisitos:
# El comando nmap debe estar instalado previamente en el sistema

set -u
# Hace que el script termine si se usa una variable no definida

# --- Configuración inicial ---
MAQUINA_TARGET="$1"  # IP o hostname del servidor objetivo

# Verificar que se recibió un argumento (aunque el script principal ya lo hace, buena práctica)
if [ -z "$MAQUINA_TARGET" ]; then
    echo "ERROR: No se recibió el argumento de máquina objetivo en el script de escaneo." >&2
    exit 1
fi

FECHA_ESCANEO=$(date +"%Y%m%d_%H%M%S")
MAQUINA_EJECUTORA=$(hostname)

# Verificar que nmap esté instalado
if ! command -v nmap &> /dev/null; then
    echo "ERROR: nmap no está instalado. Por favor instálalo manualmente." >&2
    exit 1
fi

echo "=== INICIANDO ESCANEO REMOTO DE SEGURIDAD ==="
echo "Objetivo de Escaneo: $MAQUINA_TARGET"
echo "Ejecutado desde: $MAQUINA_EJECUTORA"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "---------------------------------------------"

# --- Verificación de conectividad ---
echo -e "\n[+] Verificando conectividad con $MAQUINA_TARGET..."
# Usamos ping con 1 paquete (-c 1) y timeout de 1 segundo (-W 1)
if ping -c 1 -W 1 "$MAQUINA_TARGET" &> /dev/null; then
    echo "  Conectividad OK."
else
    echo "ERROR: No se puede alcanzar la máquina objetivo '$MAQUINA_TARGET'." >&2
    echo "Verifica la IP/hostname y la conectividad de red." >&2
    exit 1 # Salir si no hay conectividad
fi
echo "---------------------------------------------"


# --- Escaneo rápido de puertos ---
# Realiza un escaneo rápido de los 100 puertos TCP más comunes en el objetivo.
#   -F: Escaneo rápido (Fast) - Escanea solo los 100 puertos más comunes
echo -e "\n[+] Iniciando escaneo rápido de puertos TCP más comunes (-F)..."
# Capturamos el estado de salida de nmap
if ! nmap -F "$MAQUINA_TARGET"; then
    echo "ERROR: Falló el escaneo rápido de puertos." >&2
    # No salimos aquí, intentamos el siguiente escaneo si es posible
fi

# --- Escaneo detallado de servicios ---
# Realiza un escaneo más exhaustivo para detectar versiones de servicios en puertos abiertos.
#   -sV: Detección de versiones - Determina la versión de los servicios encontrados. De esta manera se puede identificar el tipo de servicio y su versión para actualizarlos y evitar vulnerabilidades.
#   Este escaneo es más lento pero proporciona información valiosa sobre los servicios

echo -e "\n[+] Detectando servicios y versiones en puertos abiertos (-sV)..."
if ! nmap -sV "$MAQUINA_TARGET"; then
    echo "ERROR: Falló la detección de servicios." >&2
    # No salimos aquí, permitimos que finalice el script
fi

echo -e "\n[+] Auditoría de red remota (escaneo de $MAQUINA_TARGET) finalizada."

# El script de escaneo finaliza siempre con éxito (exit 0) a menos que falle la conectividad
# o nmap no esté instalado. Los fallos de los escaneos individuales se reportan como ERROR
# pero no detienen el script a menos que sea un fallo fundamental.
exit 0