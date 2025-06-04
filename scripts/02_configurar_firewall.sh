#!/bin/bash
ZONA_PUBLICA_PREDETERMINADA="public" # Asumir 'public' o la interfaz de la zona activa

echo "Revisando configuración actual de firewalld..."
echo "---------------------------------------------"
sudo firewall-cmd --list-all
echo "---------------------------------------------"
echo ""
echo "Aplicando reglas de firewall para endurecimiento..."
echo "(Permitiendo solo SSH, HTTP, HTTPS. Removiendo FTP, Telnet si existen)"
echo "-------------------------------------------------------------------"

# Determinar la zona activa para la interfaz principal o usar la por defecto
# Esto es una simplificación; un sistema podría tener múltiples zonas activas.
# Para un servidor web, usualmente hay una interfaz en una zona como 'public' o 'dmz'.
ZONA_ACTIVA=$(sudo firewall-cmd --get-active-zones | head -n 1 | awk '{print $1}')
if [ -z "$ZONA_ACTIVA" ]; then
    echo "No se detectó zona activa específica, usando zona por defecto: $ZONA_PUBLICA_PREDETERMINADA"
    ZONA_ACTIVA="$ZONA_PUBLICA_PREDETERMINADA"
else
    echo "Zona activa detectada para aplicar reglas: $ZONA_ACTIVA"
fi

# Eliminar servicios potencialmente inseguros o innecesarios (si estuvieran)
SERVICIOS_A_REMOVER=("ftp" "telnet" "samba") # Añadir otros según sea necesario
for servicio in "${SERVICIOS_A_REMOVER[@]}"; do
    if sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-service="$servicio" &>/dev/null; then
        echo "Removiendo servicio $servicio de la zona $ZONA_ACTIVA..."
        sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --remove-service="$servicio"
    else
        echo "Servicio $servicio no estaba activo en la zona $ZONA_ACTIVA."
    fi
done

# Asegurar que los servicios necesarios estén presentes
SERVICIOS_A_ASEGURAR=("ssh" "http" "https")
for servicio in "${SERVICIOS_A_ASEGURAR[@]}"; do
    if ! sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-service="$servicio" &>/dev/null; then
        echo "Añadiendo servicio $servicio a la zona $ZONA_ACTIVA..."
        sudo firewall-cmd --permanent --zone="$ZONA_ACTIVA" --add-service="$servicio"
    else
        echo "Servicio $servicio ya está permitido en la zona $ZONA_ACTIVA."
    fi
done

echo ""
echo "Recargando configuración de firewalld para aplicar cambios permanentes..."
sudo firewall-cmd --reload
echo "Firewall recargado."
echo ""

echo "Configuración final de firewalld:"
echo "---------------------------------"
sudo firewall-cmd --list-all
echo "---------------------------------"