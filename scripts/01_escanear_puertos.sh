#!/bin/bash
# set -e # Descomentar si se quiere que el script falle inmediatamente en error
set -u

TARGET_HOST="localhost"
SCAN_TYPE_INFO="Escaneo de Puertos Locales en $(hostname)"

if [ -n "${1:-}" ] && [ "$1" != "localhost" ]; then # Usar ${1:-} para evitar error con set -u si $1 no está
  TARGET_HOST="$1"
  SCAN_TYPE_INFO="Escaneo de Puertos Remotos en $TARGET_HOST (desde $(hostname))"
fi

echo "INFO: Iniciando $SCAN_TYPE_INFO"
echo "INFO: Objetivo del escaneo: $TARGET_HOST"

if ! command -v nmap &> /dev/null; then
  echo "AVISO: nmap no está instalado."
  # No preguntaremos interactivamente aquí, ya que la salida va a un log.
  # El script principal podría manejar la instalación o el usuario debe pre-instalar.
  echo "ACCION REQUERIDA: Por favor, instale nmap (ej: sudo dnf install -y nmap) para habilitar este escaneo."
  exit 1 # Salir con error para que auditoria_principal lo note
fi

echo "INFO: Ejecutando nmap -sT -F $TARGET_HOST ..."
echo "(Esta operación puede tardar unos momentos)"

if [ "$TARGET_HOST" == "localhost" ]; then
    if command -v sudo &> /dev/null; then
        sudo nmap -sT -F "$TARGET_HOST"
    else
        echo "AVISO: sudo no está disponible. Ejecutando nmap sin privilegios elevados para localhost."
        nmap -sT -F "$TARGET_HOST"
    fi
else
    nmap -sT -F "$TARGET_HOST"
fi
NMAP_EXIT_CODE=$?

if [ $NMAP_EXIT_CODE -ne 0 ]; then
    echo "ADVERTENCIA: nmap finalizó con código de error $NMAP_EXIT_CODE. El escaneo puede ser incompleto."
fi

echo "INFO: Escaneo básico completado."
echo "SUGERENCIA: Para un escaneo más completo (todos los puertos TCP): nmap -sT -p- $TARGET_HOST"
echo "SUGERENCIA: Para un escaneo de puertos UDP (más lento): sudo nmap -sU -F $TARGET_HOST"