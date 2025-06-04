#!/bin/bash
set -u

ZONA_ACTIVA=$(sudo firewall-cmd --get-active-zones | head -n 1 | awk '{print $1}')
[ -z "$ZONA_ACTIVA" ] && ZONA_ACTIVA="public"

echo "Zona Firewall Activa/Defecto: $ZONA_ACTIVA"
echo "Estado Actual Firewall:"
sudo firewall-cmd --list-services --zone="$ZONA_ACTIVA"
sudo firewall-cmd --list-ports --zone="$ZONA_ACTIVA"
echo "---"

SERVICIOS_A_REMOVER=("ftp" "telnet")
for servicio in "${SERVICIOS_A_REMOVER[@]}"; do
    sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --remove-service="$servicio" &>/dev/null
done

SERVICIOS_A_ASEGURAR=("ssh" "http" "https")
for servicio in "${SERVICIOS_A_ASEGURAR[@]}"; do
    sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --add-service="$servicio" &>/dev/null
done

echo "Recargando firewall..."
if sudo firewall-cmd --reload; then
    echo "Firewall recargado. Configuración final:"
    sudo firewall-cmd --list-services --zone="$ZONA_ACTIVA"
    sudo firewall-cmd --list-ports --zone="$ZONA_ACTIVA"
else
    echo "ERROR: Falló la recarga del firewall."
    exit 1
fi