#!/bin/bash
# set -e
set -u

DIAS_A_REVISAR="1"
MAX_LINEAS_LOG=30

echo "INFO: Analizando logs de autenticación y SSH recientes."
echo "      (Buscando eventos relevantes de los últimos $DIAS_A_REVISAR día(s), máx $MAX_LINEAS_LOG líneas por categoría)"
echo "--------------------------------------------------------------------------------"

if command -v journalctl &> /dev/null; then
    echo "[Eventos de SSH (sshd)]"
    sudo journalctl -u sshd --since "${DIAS_A_REVISAR} day ago" --no-pager -n $MAX_LINEAS_LOG --output=short-iso
    
    echo ""
    echo "[Intentos de login fallidos (todos los métodos)]"
    sudo journalctl _SYSTEMD_UNIT=systemd-logind.service SYSLOG_IDENTIFIER=login PRIORITY=warning --since "${DIAS_A_REVISAR} day ago" --no-pager -n $MAX_LINEAS_LOG --output=short-iso
    # O un grep más amplio si es necesario
    # sudo journalctl --since "${DIAS_A_REVISAR} day ago" | grep -iE 'fail|denied|refused|invalid user' | tail -n $MAX_LINEAS_LOG
else
    echo "AVISO: journalctl no disponible. Intentando con /var/log/secure..."
    if [ -f /var/log/secure ]; then
        sudo grep -iE "Failed|Accepted|Disconnected|Invalid user|refused" /var/log/secure | tail -n $MAX_LINEAS_LOG
    else
        echo "ERROR: No se encontró /var/log/secure y journalctl no está disponible. No se pueden mostrar logs."
        exit 1
    fi
fi
echo "--------------------------------------------------------------------------------"