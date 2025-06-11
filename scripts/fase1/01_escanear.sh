#!/bin/bash
set -u

TARGET="$1"
[[ -n "$TARGET" ]] || { echo "Falta argumento TARGET"; exit 1; }

echo "[*] Verificando conectividad con $TARGET..."
ping -c1 -W1 "$TARGET" &>/dev/null || { echo "No hay conectividad"; exit 1; }

echo "[+] Escaneo rápido de puertos (-F)"
nmap -F "$TARGET" || echo "[!] Falló escaneo rápido"

echo "[+] Escaneo detallado de servicios (-sV)"
nmap -sV "$TARGET" || echo "[!] Falló escaneo detallado"

echo "[✓] Escaneo finalizado"