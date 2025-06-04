#!/bin/bash
# set -e
set -u

ZONA_PUBLICA_PREDETERMINADA="public"

echo "INFO: Iniciando configuración/verificación de Firewall (firewalld)."
echo "INFO: Estado actual del firewall:"
sudo firewall-cmd --list-all
echo "---------------------------------------------"

ZONA_ACTIVA=$(sudo firewall-cmd --get-active-zones | head -n 1 | awk '{print $1}')
if [ -z "$ZONA_ACTIVA" ]; then
    echo "INFO: No se detectó zona activa específica, usando zona por defecto: $ZONA_PUBLICA_PREDETERMINADA"
    ZONA_ACTIVA="$ZONA_PUBLICA_PREDETERMINADA"
else
    echo "INFO: Zona activa detectada para aplicar reglas: $ZONA_ACTIVA"
fi

echo "INFO: Aplicando reglas de endurecimiento (permitir SSH, HTTP, HTTPS; remover otros)..."

SERVICIOS_A_REMOVER=("ftp" "telnet" "samba")
for servicio in "${SERVICIOS_A_REMOVER[@]}"; do
    if sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-service="$servicio" &>/dev/null; then
        echo "INFO: Removiendo servicio $servicio de la zona $ZONA_ACTIVA..."
        sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --remove-service="$servicio"
    else
        echo "DEBUG: Servicio $servicio no estaba activo/configurado en la zona $ZONA_ACTIVA."
    fi
done

SERVICIOS_A_ASEGURAR=("ssh" "http" "https")
for servicio in "${SERVICIOS_A_ASEGURAR[@]}"; do
    if ! sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-service="$servicio" &>/dev/null; then
        echo "INFO: Añadiendo servicio $servicio a la zona $ZONA_ACTIVA..."
        sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --add-service="$servicio"
    else
        echo "DEBUG: Servicio $servicio ya está permitido en la zona $ZONA_ACTIVA."
    fi
done

echo "INFO: Recargando configuración de firewalld..."
if sudo firewall-cmd --reload; then
    echo "INFO: Firewall recargado exitosamente."
else
    echo "ERROR: Falló la recarga del firewall. Revisar manualmente."
    exit 1
fi

echo ""
echo "INFO: Configuración final del firewall:"
sudo firewall-cmd --list-all
echo "---------------------------------"