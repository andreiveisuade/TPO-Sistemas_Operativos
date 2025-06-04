#!/bin/bash
# Configuración segura del firewall (firewalld)
# Este script configura el firewall basado en los puertos abiertos detectados

set -u  # Falla si hay variables no definidas

# Verificar si la variable de entorno está definida
if [ -z "${PUERTOS_ABIERTOS:-}" ]; then
    echo "Error: No se encontró la variable PUERTOS_ABIERTOS."
    echo "Ejecuta primero el script 01_escanear_puertos.sh con 'source' o '.'"
    echo "Ejemplo: . ./01_escanear_puertos.sh"
    exit 1
fi

# Función para mostrar mensajes de error y salir
fatal() {
    echo "Error: $1" >&2
    exit 1
}

# Verificar si el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    fatal "Este script debe ejecutarse como superusuario (root)"
fi

# Verificar si firewalld está instalado
if ! command -v firewall-cmd &> /dev/null; then
    fatal "firewalld no está instalado. Instálalo con:\n  - RedHat/Fedora: dnf install firewalld\n  - Debian/Ubuntu: apt install firewalld"
fi

# Iniciar firewalld si no está activo
if ! systemctl is-active --quiet firewalld; then
    echo "Iniciando firewalld..."
    systemctl enable --now firewalld || fatal "No se pudo iniciar firewalld"
fi

# Detectar zona activa o usar 'public' por defecto
ZONA_ACTIVA=$(firewall-cmd --get-active-zones | awk 'NR==1 {print $1}')
ZONA_ACTIVA=${ZONA_ACTIVA:-public}

echo "=== CONFIGURACIÓN DE FIREWALL ==="
echo "Zona activa: $ZONA_ACTIVA"

# Hacer una copia de seguridad de la configuración actual
FECHA=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/etc/firewalld/backups/firewall_backup_${FECHA}.xml"
mkdir -p /etc/firewalld/backups/
cp /etc/firewalld/zones/${ZONA_ACTIVA}.xml "$BACKUP_FILE"
echo "Copia de seguridad de la configuración actual guardada en: $BACKUP_FILE"

# Configuración por defecto: denegar todo el tráfico entrante
firewall-cmd --permanent --zone=$ZONA_ACTIVA --set-target=DROP

# Permitir tráfico de loopback
firewall-cmd --permanent --zone=$ZONA_ACTIVA --add-interface=lo

# Servicios esenciales que SIEMPRE deben estar permitidos
SERVICIOS_ESENCIALES=("ssh" "dhcpv6-client" "mdns" "samba-client")
for svc in "${SERVICIOS_ESENCIALES[@]}"; do
    if ! firewall-cmd --zone=$ZONA_ACTIVA --query-service=$svc &>/dev/null; then
        echo "➕ Permitir servicio esencial: $svc"
        firewall-cmd --permanent --zone=$ZONA_ACTIVA --add-service=$svc
    fi
done

# Leer puertos abiertos de la variable de entorno
echo "\n=== CONFIGURANDO PUERTOS ==="
if [ -n "$PUERTOS_ABIERTOS" ]; then
    echo "Puertos abiertos detectados que se mantendrán habilitados:"
    for puerto in $PUERTOS_ABIERTOS; do
        # Verificar si el puerto no es un servicio esencial ya permitido
        ES_SERVICIO_ESENCIAL=0
        for svc in "${SERVICIOS_ESENCIALES[@]}"; do
            if firewall-cmd --zone=$ZONA_ACTIVA --query-service=$svc &>/dev/null; then
                if firewall-cmd --zone=$ZONA_ACTIVA --service=$svc --query-port=$puerto/tcp &>/dev/null || \
                   firewall-cmd --zone=$ZONA_ACTIVA --service=$svc --query-port=$puerto/udp &>/dev/null; then
                    ES_SERVICIO_ESENCIAL=1
                    break
                fi
            fi
        done
        
        if [ "$ES_SERVICIO_ESENCIAL" -eq 0 ]; then
            echo "  🔓 Manteniendo puerto abierto: $puerto/tcp"
            firewall-cmd --permanent --zone=$ZONA_ACTIVA --add-port=$puerto/tcp
        fi
    done
else
    echo "No se detectaron puertos abiertos adicionales."
fi

# Recargar la configuración del firewall
echo "\nAplicando cambios..."
firewall-cmd --reload

# Mostrar resumen de la configuración
echo "\n=== RESUMEN DE CONFIGURACIÓN ==="
echo "Zona: $ZONA_ACTIVA"
echo "Política por defecto: DROP"
echo "\nServicios permitidos:"
firewall-cmd --zone=$ZONA_ACTIVA --list-services

echo "\nPuertos permitidos:"
firewall-cmd --zone=$ZONA_ACTIVA --list-ports

echo "\n✅ Configuración del firewall completada con éxito."
echo "Se recomienda revisar la configuración y reiniciar el servicio si es necesario:"
echo "  systemctl restart firewalld"