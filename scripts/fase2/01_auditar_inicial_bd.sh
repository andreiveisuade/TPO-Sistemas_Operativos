#!/bin/bash

# Muestra información básica sobre servicios y conexiones locales

echo "[+] Servicios habilitados al arranque"
systemctl list-unit-files --type=service --state=enabled

echo "[+] Servicios en ejecución"
systemctl list-units --type=service --state=running

echo "[+] Conexiones activas"
ss -tulnp | grep ESTAB

echo "[+] Puertos escuchando"
ss -tulnp | grep LISTEN