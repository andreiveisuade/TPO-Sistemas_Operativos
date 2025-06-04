#!/bin/bash
# Este script espera la IP del servidor de BD como primer argumento si se va a escanear remotamente.
# Si no se pasa argumento, escanea localhost.

TARGET_HOST="localhost"
SCAN_TYPE="Escaneo de Puertos Locales"

if [ -n "$1" ]; then
  TARGET_HOST="$1"
  SCAN_TYPE="Escaneo de Puertos Remotos en $TARGET_HOST (desde $(hostname))"
fi

echo "$SCAN_TYPE"
echo "-------------------------------------"

if ! command -v nmap &> /dev/null; then
  echo "AVISO: nmap no está instalado. Saltando escaneo de puertos."
  echo "Para instalar nmap, ejecute: sudo dnf install -y nmap"
  exit 0
fi

echo "Ejecutando nmap -sT -F $TARGET_HOST ..."
echo "(Esto puede tardar unos momentos)"
# Si el script principal corre como root, nmap también lo hará.
# Si no, y se escanea localhost, podría necesitar sudo para ciertos tipos de escaneo,
# pero -sT (TCP connect scan) generalmente no requiere root si no se escanea a uno mismo.
# Para escaneos a localhost, -sT es menos privilegiado.
# Para escaneos remotos, nmap funciona sin sudo para -sT.
if [ "$TARGET_HOST" == "localhost" ]; then
    sudo nmap -sT -F "$TARGET_HOST" # -F escanea los 100 puertos más comunes
else
    nmap -sT -F "$TARGET_HOST"
fi

echo "-------------------------------------"
echo "Análisis de puertos adicionales más comunes (si es necesario profundizar):"
echo "Para un escaneo más completo de todos los puertos TCP: nmap -sT -p- $TARGET_HOST"
echo "Para un escaneo de puertos UDP (más lento y menos fiable): sudo nmap -sU -F $TARGET_HOST"