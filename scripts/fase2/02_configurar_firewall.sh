#!/bin/bash
# Script para configurar el firewall en el SERVIDOR DE BASE DE DATOS
# ESTE SCRIPT SE EJECUTA COMO ROOT MEDIANTE "sudo bash -s" DESDE EL SCRIPT auditoria_fase2.sh
set -u
set -e

PUERTOS_BD_ABIERTOS=("3306/tcp")
SERVICIOS_A_REMOVER=("http" "https" "ftp" "telnet" "samba")

[[ -x "$(command -v firewall-cmd)" ]] || { echo "No está firewalld"; exit 1; }
systemctl enable --now firewalld

ZONA=$(firewall-cmd --get-default-zone)
echo "[*] Configurando zona: $ZONA"

for s in "${SERVICIOS_A_REMOVER[@]}"; do
  firewall-cmd --permanent --zone="$ZONA" --remove-service="$s" 2>/dev/null || true
done

firewall-cmd --permanent --zone="$ZONA" --add-service=ssh

for p in "${PUERTOS_BD_ABIERTOS[@]}"; do
  firewall-cmd --permanent --zone="$ZONA" --add-port="$p"
done

firewall-cmd --reload
firewall-cmd --zone="$ZONA" --list-all