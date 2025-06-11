#!/bin/bash
# Script para configurar el firewall en el SERVIDOR DE BASE DE DATOS
# ESTE SCRIPT SE EJECUTA COMO ROOT MEDIANTE "sudo bash -s" DESDE EL SCRIPT auditoria_fase2.sh
set -u
set -e

# <--- MODIFICACIÓN: Se ha añadido un comentario para justificar esta configuración ---
# El escaneo de Fase 1 confirmó que el servicio MySQL/MariaDB está en el puerto 3306.
# Este es el único puerto de aplicación que dejaremos abierto.
PUERTOS_BD_ABIERTOS=("3306/tcp") 

echo "=== CONFIGURACIÓN DE FIREWALL EN SERVIDOR DE BASE DE DATOS ($(hostname)) ==="
echo "INFO: Ejecutando con privilegios de root."

if ! command -v firewall-cmd &> /dev/null; then
    echo "ERROR: firewalld no está instalado. Instalar con: dnf install -y firewalld (o equivalente)"
    exit 1
fi

if ! systemctl is-active --quiet firewalld; then
    echo "INFO: firewalld no está activo. Intentando iniciar y habilitar..."
    systemctl enable --now firewalld || { echo "ERROR: No se pudo iniciar firewalld."; exit 1; }
fi

ZONA_ACTIVA=$(firewall-cmd --get-default-zone)
echo "INFO: Se aplicarán reglas a la zona por defecto: $ZONA_ACTIVA"

echo "INFO: Estado actual del firewall en zona '$ZONA_ACTIVA':"
firewall-cmd --zone="$ZONA_ACTIVA" --list-all
echo "--------------------------------------------------"

echo "INFO: Aplicando política restrictiva..."
# <--- MODIFICACIÓN: Comentario añadido para explicar la selección de servicios a remover ---
# Basado en el escaneo de Fase 1, los servicios http y https (puertos 80 y 443) estaban abiertos.
# Estos servicios son innecesarios y representan un riesgo en un servidor de BD dedicado.
# Los incluimos aquí junto con otros servicios comúnmente inseguros para asegurarnos de que el firewall los bloquee.
SERVICIOS_A_REMOVER=("ftp" "telnet" "samba" "http" "https") 
for servicio in "${SERVICIOS_A_REMOVER[@]}"; do
    if firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-service="$servicio" &>/dev/null; then
        echo "  Removiendo servicio innecesario/inseguro: $servicio"
        firewall-cmd --permanent --zone="$ZONA_ACTIVA" --remove-service="$servicio"
    fi
done

# <--- SIN MODIFICACIÓN: Se mantiene ssh como servicio esencial para la administración ---
SERVICIOS_A_ASEGURAR=("ssh") 
for servicio in "${SERVICIOS_A_ASEGURAR[@]}"; do
    if ! firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-service="$servicio" &>/dev/null; then
        echo "  Añadiendo servicio esencial: $servicio"
        firewall-cmd --permanent --zone="$ZONA_ACTIVA" --add-service="$servicio"
    fi
done

for puerto_bd in "${PUERTOS_BD_ABIERTOS[@]}"; do
    if ! firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-port="$puerto_bd" &>/dev/null; then
        echo "  Permitiendo puerto de base de datos: $puerto_bd"
        firewall-cmd --permanent --zone="$ZONA_ACTIVA" --add-port="$puerto_bd"
    else
        echo "  Puerto de base de datos $puerto_bd ya permitido."
    fi
done


echo "INFO: Recargando firewalld para aplicar las nuevas reglas..."
if firewall-cmd --reload; then
    echo "INFO: Firewall recargado."
else
    echo "ERROR: Falló la recarga del firewall."
    exit 1
fi

echo "INFO: Configuración final del firewall en zona '$ZONA_ACTIVA':"
firewall-cmd --zone="$ZONA_ACTIVA" --list-all
echo "--------------------------------------------------"
echo "✅ Configuración del firewall del servidor de BD completada ✅"
