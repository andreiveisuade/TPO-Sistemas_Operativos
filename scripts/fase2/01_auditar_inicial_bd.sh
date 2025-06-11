#!/bin/bash
# Script a ejecutar en el SERVIDOR DE BASE DE DATOS
# Este script realiza una auditoría inicial de servicios y conexiones LOCALES.
# Se ejecuta como root mediante "sudo bash -s" desde auditoria_fase2.sh.
set -u
set -e

echo "=== AUDITORÍA INICIAL DE SERVICIOS Y CONEXIONES (en $(hostname)) ==="
echo "INFO: Ejecutando con privilegios de root."
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "------------------------------------------------------------------"

echo -e "\n[+] Servicios habilitados para iniciar al arranque (systemctl --state=enabled):"
systemctl list-unit-files --type=service --state=enabled --no-pager | awk '{print "  " $1, $2}' | grep -vE '^UNIT|^$'
echo "---"

echo -e "\n[+] Servicios actualmente EJECUTÁNDOSE (systemctl --state=running):"
systemctl list-units --type=service --state=running --no-pager | awk '{print "  " $1}' | grep -vE '^UNIT|^$'
echo "---"

echo -e "\n[+] Conexiones de red activas (ESTABLISHED) con detalles de proceso (ss -tulnp):"
# ss es el reemplazo moderno de netstat. -tulnp: TCP/UDP, listening, established, process, numeric
ss -tulnp | grep 'ESTAB'
echo "---"

echo -e "\n[+] Puertos escuchando (LISTEN) en esta máquina (ss -tulnp):"
ss -tulnp | grep 'LISTEN'
echo "---"

echo "✅ Auditoría inicial de servicios y conexiones completada ✅"
