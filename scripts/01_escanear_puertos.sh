#!/bin/bash
set -u

TARGET_HOST="localhost"
if [ -n "${1:-}" ] && [ "$1" != "localhost" ]; then TARGET_HOST="$1"; fi

echo "Objetivo Escaneo: $TARGET_HOST"

if ! command -v nmap &> /dev/null; then
  echo "ERROR: nmap no está instalado. Se requiere para escanear puertos."
  echo "Instalar con: sudo dnf install -y nmap"
  exit 1
fi

echo "Ejecutando nmap -sT -F $TARGET_HOST ..."
if [ "$TARGET_HOST" == "localhost" ]; then
    sudo nmap -sT -F "$TARGET_HOST"
else
    nmap -sT -F "$TARGET_HOST"
fi
exit $?