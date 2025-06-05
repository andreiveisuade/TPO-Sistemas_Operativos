#!/bin/bash
# Establece el intérprete de comandos a usar (bash)

# Configuración de opciones del shell:
# -u: Genera un error al usar variables no definidas
set -u

# Obtener la dirección IP objetivo pasada como primer argumento
TARGET="$1"

# Cargar funciones auxiliares desde el archivo utilidades.sh
# $(dirname "$0") obtiene el directorio donde está este script
# y luego se mueve un nivel arriba (..) para encontrar utilidades.sh
source "$(dirname "$0")/../utilidades.sh"

# Verificar e instalar comandos necesarios si no están presentes
# asegurar_comando es una función definida en utilidades.sh
asegurar_comando nmap       # Herramienta de escaneo de red
asegurar_comando netstat net-tools  # Utilidad para mostrar conexiones de red

echo "=== RUTINA DE SEGURIDAD REMOTA ==="
echo "Objetivo: $TARGET"
echo "Fecha: $(date)"  # Muestra la fecha y hora actual
echo "-----------------------------"

# Escaneo básico de puertos TCP abiertos
# -sT: Escaneo TCP connect()
# -p-: Escanea todos los puertos (1-65535)
echo ""
echo "Escaneo de puertos TCP (nmap -sT)"
sudo nmap -sT -p- "$TARGET"

# Detección de versiones de servicios
# -sV: Detecta versiones de servicios en puertos abiertos
echo ""
echo "Servicios y versiones detectados (nmap -sV)"
sudo nmap -sV "$TARGET"

# Listar servicios configurados para iniciar al arranque
# --type=service: Muestra solo servicios (no sockets, targets, etc.)
# grep enabled: Filtra solo los servicios habilitados
echo ""
echo "Servicios habilitados al arranque (systemctl)"
systemctl list-unit-files --type=service | grep enabled

# Mostrar conexiones de red activas
# -a: Muestra todas las conexiones
# -n: Muestra direcciones numéricas en lugar de resolver nombres
# -t: Muestra solo conexiones TCP
# -p: Muestra el PID y nombre del proceso
# grep ESTABLISHED: Filtra solo conexiones establecidas
echo ""
echo "Conexiones activas (netstat)"
netstat -antp | grep ESTABLISHED

echo ""
echo "Auditoría de red finalizada."