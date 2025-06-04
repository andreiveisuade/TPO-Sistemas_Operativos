#!/bin/bash
set -u

DIAS_A_REVISAR="1"
MAX_LINEAS_LOG=20

echo "Eventos SSH (sshd) últimos $DIAS_A_REVISAR día(s), máx $MAX_LINEAS_LOG líneas:"
if command -v journalctl &> /dev/null; then
    sudo journalctl -u sshd --since "${DIAS_A_REVISAR}d ago" -n $MAX_LINEAS_LOG --no-pager --output=short-iso
    echo "---"
    echo "Intentos de login fallidos (journal) últimos $DIAS_A_REVISAR día(s), máx $MAX_LINEAS_LOG:"
    sudo journalctl _SYSTEMD_UNIT=systemd-logind.service SYSLOG_IDENTIFIER=login PRIORITY=warning --since "${DIAS_A_REVISAR}d ago" -n $MAX_LINEAS_LOG --no-pager --output=short-iso
elif [ -f /var/log/secure ]; then
    echo "AVISO: journalctl no disponible. Usando /var/log/secure."
    sudo grep -iE "Failed|Accepted|Invalid user" /var/log/secure | tail -n $(($MAX_LINEAS_LOG * 2)) # *2 para compensar
else
    echo "ERROR: No se pueden leer logs de autenticación (ni journalctl ni /var/log/secure)."
    exit 1
fi