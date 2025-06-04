#!/bin/bash
DIAS_A_REVISAR="1" # Cuántos días hacia atrás revisar en el journal

echo "Analizando logs de autenticación y SSH recientes (últimas 50 entradas relevantes)..."
echo "--------------------------------------------------------------------------------"
# Usar journalctl para sistemas modernos RHEL, es más potente.
if command -v journalctl &> /dev/null; then
    echo "Eventos de SSH (sshd) de las últimas 24 horas (o $DIAS_A_REVISAR días):"
    sudo journalctl -u sshd --since "${DIAS_A_REVISAR} day ago" --no-pager -n 50
    
    echo ""
    echo "Intentos de login fallidos (todos los métodos) de las últimas 24 horas (o $DIAS_A_REVISAR días):"
    sudo journalctl _SYSTEMD_UNIT=systemd-logind.service PRIORITY=warning --since "${DIAS_A_REVISAR} day ago" --no-pager -n 50
    # O un grep más genérico si se prefiere, aunque menos preciso
    # sudo journalctl --since "${DIAS_A_REVISAR} day ago" | grep -iE 'fail|failed|denied|refused|invalid user' | tail -n 50
else
    echo "journalctl no disponible. Intentando con /var/log/secure..."
    if [ -f /var/log/secure ]; then
        sudo grep -iE "Failed|Accepted|Disconnected|Invalid user|refused" /var/log/secure | tail -n 50
    else
        echo "AVISO: No se encontró /var/log/secure. No se pueden mostrar logs de autenticación."
    fi
fi
echo "--------------------------------------------------------------------------------"
echo "Revisar manualmente los logs para actividad inusual o no autorizada."