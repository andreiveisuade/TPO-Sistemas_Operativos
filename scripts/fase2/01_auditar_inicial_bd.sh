#!/bin/bash

# Muestra información básica sobre servicios y conexiones locales

echo "========== AUDITORÍA DE SERVICIOS Y CONEXIONES =========="
echo "Hostname: $(hostname)"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"

echo -e "\n[+] Servicios habilitados al arranque"
systemctl list-unit-files --type=service --state=enabled

echo -e "\n[+] Servicios en ejecución"
systemctl list-units --type=service --state=running

echo -e "\n[+] Conexiones activas (ESTABLISHED)"
ss -tulnp | grep ESTAB

echo -e "\n[+] Puertos escuchando (LISTEN)"
ss -tulnp | grep LISTEN