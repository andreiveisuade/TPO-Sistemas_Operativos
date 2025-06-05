#!/bin/bash
set -u

# Verificar privilegios de root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Este script debe ejecutarse como root."
    exit 1
fi

# Verificar si firewalld está instalado
if ! command -v firewall-cmd &>/dev/null; then
    echo "❌ firewalld no está instalado."
    exit 1
fi

# Iniciar firewalld si no está activo
if ! systemctl is-active --quiet firewalld; then
    echo "⚙️ Iniciando firewalld..."
    systemctl enable --now firewalld || {
        echo "❌ No se pudo iniciar firewalld."
        exit 1
    }
fi

# Obtener zona activa
ZONA_ACTIVA=$(firewall-cmd --get-active-zones | awk 'NR==1 {print $1}')
ZONA_ACTIVA=${ZONA_ACTIVA:-public}
echo "🌐 Zona activa detectada: $ZONA_ACTIVA"

# Definir listas de servicios
SERVICIOS_OK=("ssh" "http" "https")
SERVICIOS_INSEGUROS=("ftp" "telnet" "samba" "smtp")

echo ""
echo "🧹 Eliminando servicios inseguros..."
for svc in "${SERVICIOS_INSEGUROS[@]}"; do
    if firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-service="$svc" &>/dev/null; then
        firewall-cmd --permanent --zone="$ZONA_ACTIVA" --remove-service="$svc"
        echo "  🔻 Eliminado: $svc"
    fi
done

echo ""
echo "✅ Asegurando servicios esenciales..."
for svc in "${SERVICIOS_OK[@]}"; do
    if ! firewall-cmd --permanent --zone="$ZONA_ACTIVA" --query-service="$svc" &>/dev/null; then
        firewall-cmd --permanent --zone="$ZONA_ACTIVA" --add-service="$svc"
        echo "  ➕ Permitido: $svc"
    fi
done

# Recargar configuración
echo ""
echo "♻️ Recargando configuración del firewall..."
firewall-cmd --reload

# Mostrar configuración final
echo ""
echo "🎯 Configuración final de servicios permitidos en zona '$ZONA_ACTIVA':"
firewall-cmd --zone="$ZONA_ACTIVA" --list-services