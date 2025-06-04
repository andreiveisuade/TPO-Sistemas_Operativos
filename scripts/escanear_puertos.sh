#!/bin/bash
echo "[Escaneo de Puertos]"
if command -v nmap >/dev/null 2>&1; then
  sudo nmap -sT -F localhost
else
  echo "nmap no está instalado. Saltando."
fi