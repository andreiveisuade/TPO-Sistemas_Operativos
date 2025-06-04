#!/bin/bash
echo "[Revisión de Permisos]"
ls -l /etc/shadow
ls -l /etc/passwd
ls -ld /root

echo "[Ajustando permisos...]"
sudo chmod 600 /etc/shadow
sudo chmod 644 /etc/passwd
sudo chmod 700 /root