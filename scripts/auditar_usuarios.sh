#!/bin/bash
echo "[Auditoría de Usuarios]"
cut -d: -f1 /etc/passwd
awk -F: '$3 == 0 { print "Usuario con UID 0: " $1 }' /etc/passwd
sudo awk -F: '$2 == "" { print "Contraseña vacía: " $1 }' /etc/shadow