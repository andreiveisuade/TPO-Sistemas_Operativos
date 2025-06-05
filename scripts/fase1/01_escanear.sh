#!/bin/bash
# Script para realizar un escaneo de seguridad remota
set -u

TARGET_IP="$1"

# --- Cargar Utilidades ---
# Construye la ruta al directorio raíz del proyecto (asumiendo que 01_escanear.sh está en scripts/fase1/)
# y luego busca utilidades.sh en la raíz.
SCRIPT_DIR_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
if [ -f "$SCRIPT_DIR_ROOT/utilidades.sh" ]; then
    source "$SCRIPT_DIR_ROOT/utilidades.sh"
else
    echo "ERROR CRÍTICO: No se pudo encontrar utilidades.sh en $SCRIPT_DIR_ROOT. Abortando escaneo."
    exit 1
fi
# --- Fin Cargar Utilidades ---

# Verificar e instalar dependencias necesarias
asegurar_comando "nmap"       || exit 1 # Salir si nmap no se puede asegurar
asegurar_comando "netstat" "net-tools" # Continuar si netstat falla, pero loguear

echo ""
echo "=== RUTINA DE SEGURIDAD REMOTA (Escaneo desde $(hostname)) ==="
echo "Objetivo: $TARGET_IP"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "----------------------------------------------------------"

echo -e "\n[+] Iniciando escaneo rápido de puertos TCP más comunes (-F)..."
# nmap -F no requiere sudo para escaneo TCP connect a un host remoto
nmap -F "$TARGET_IP"
echo "---"

echo -e "\n[+] Detectando servicios y versiones (-sV) en puertos abiertos..."
# nmap -sV tampoco requiere sudo para escaneo TCP connect a un host remoto si los puertos son >1023
# o si el usuario tiene capacidades cap_net_raw. Por seguridad y consistencia,
# para detección de versiones que puede intentar más cosas, usar sudo es más robusto
# si el script principal es ejecutado por un usuario con privilegios sudo.
# Sin embargo, para un escaneo remoto desde una máquina de 'aplicaciones' a una de 'bd',
# el usuario de la máquina de aplicaciones NO tendrá sudo en la máquina de BD.
# Por lo tanto, los comandos de nmap deben ser ejecutables por un usuario normal.
# Si se escanea localhost y se quieren versiones de servicios en puertos <1024, se necesitaría sudo.
# Dado que es un escaneo REMOTO, no usamos sudo para nmap aquí.
nmap -sV "$TARGET_IP"
echo "---"

echo -e "\n[+] Servicios habilitados para iniciar al arranque en $TARGET_IP (información obtenida remotamente si posible, sino local):"
echo "NOTA: Obtener esta información remotamente sin un agente o acceso SSH directo es complejo."
echo "      Se mostrará información local de los servicios habilitados en ESTA máquina ($(hostname))."
echo "      Para el servidor objetivo, esta verificación debe hacerse localmente en él."
systemctl list-unit-files --type=service --state=enabled --no-pager | awk '{print "  " $1, $2}' | grep -vE '^UNIT|^$'
echo "---"

echo -e "\n[+] Conexiones activas ESTABLECIDAS en ESTA máquina ($(hostname)) (netstat):"
echo "NOTA: Para ver conexiones del servidor objetivo, este comando debe ejecutarse en él."
# Si netstat no fue asegurado (instalado) por asegurar_comando, este comando fallará.
if command -v netstat &> /dev/null; then
    # Para ver los PIDs, netstat necesita sudo. Como es informativo, se puede omitir sudo si no se es root.
    if [ "$(id -u)" -eq 0 ]; then
        netstat -antp | grep 'ESTABLISHED'
    else
        netstat -ant | grep 'ESTABLISHED'
        echo "  (Para ver PIDs/Nombres de programa, ejecute como root o con sudo)"
    fi
else
    echo "AVISO: netstat (del paquete net-tools) no está disponible para mostrar conexiones."
fi
echo "---"

echo -e "\nAuditoría de red (escaneo desde $(hostname) a $TARGET_IP) finalizada."