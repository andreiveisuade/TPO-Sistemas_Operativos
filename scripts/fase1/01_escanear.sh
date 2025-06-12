#!/bin/bash

# Escanea puertos abiertos y versiones de servicios en una máquina remota
MAQUINA_TARGET="$1"

echo "[+] Escaneo rápido de puertos (-F)"
nmap -F "$MAQUINA_TARGET"

echo "[+] Detección de versiones de servicios (-sV)"
nmap -sV "$MAQUINA_TARGET"