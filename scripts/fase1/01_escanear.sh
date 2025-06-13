#!/bin/bash

# Escanea puertos abiertos y versiones de servicios en una máquina remota
MAQUINA_TARGET="$1"

echo "[+] Escaneo rápido de puertos (-F) y detección de versiones de servicios (-sV)"
nmap -F -sV "$MAQUINA_TARGET"