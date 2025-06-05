#!/bin/bash
# Script para realizar un escaneo de seguridad remota
# Incluye detección de puertos abiertos, servicios y conexiones activas

# Configuración de opciones del shell para mayor seguridad
# -u: Genera un error al usar variables no definidas
set -u

# Obtener la dirección IP objetivo del primer argumento
TARGET="$1"

# Importar funciones auxiliares
# $(dirname "$0") obtiene el directorio del script actual
# Se navega un nivel arriba (..) para localizar utilidades.sh
source "$(dirname "$0")/../utilidades.sh"

# Verificar e instalar dependencias necesarias
# asegurar_comando es una función definida en utilidades.sh
asegurar_comando nmap       # Herramienta de escaneo de red
asegurar_comando netstat net-tools  # Utilidad para monitoreo de red

echo "=== RUTINA DE SEGURIDAD REMOTA ==="
echo "Objetivo: $TARGET"
echo "Fecha: $(date)"  # Muestra la fecha y hora actual
echo "-----------------------------"

# Escaneo rápido de puertos TCP más comunes
# -sT: Escaneo TCP connect()
# -F: Escaneo rápido (solo los 100 puertos más comunes)
echo -e "\nIniciando escaneo rápido de puertos más comunes..."
sudo nmap -F "$TARGET"

# Detección detallada de versiones de servicios
# -sV: Detecta versiones de servicios en puertos abiertos
echo -e "\nServicios y versiones detectados (nmap -sV)"
sudo nmap -sV "$TARGET"

# Listar servicios configurados para iniciar automáticamente
# --type=service: Filtra solo servicios (no sockets, targets, etc.)
# grep enabled: Muestra únicamente servicios habilitados
echo -e "\nServicios habilitados al arranque (systemctl)"
systemctl list-unit-files --type=service | grep enabled

# Mostrar conexiones de red activas establecidas
# -a: Muestra todas las conexiones
# -n: No resuelve nombres de host (solo IPs)
# -t: Filtra solo conexiones TCP
# -p: Muestra el PID y nombre del proceso asociado
echo -e "\nConexiones activas (netstat)"
netstat -antp | grep ESTABLISHED

echo -e "\nAuditoría de red finalizada."