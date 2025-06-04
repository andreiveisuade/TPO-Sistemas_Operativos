#!/bin/bash
set -u

echo "Usuarios con UID 0 (root):"
awk -F: '($3 == 0) { print "  " $1 }' /etc/passwd
echo "---"
echo "Usuarios 'humanos' (UID >= 1000):"
awk -F: '($3 >= 1000 && $3 != 65534) { print "  " $1 " (Shell: " $7 ")" }' /etc/passwd
echo "---"
echo "Verificando /etc/shadow (contraseñas vacías/bloqueadas):"
sudo awk -F: '{ if ($2 == "") print "  ALERTA VACÍA: " $1; else if (substr($2,1,1) == "!" || substr($2,1,1) == "*") print "  INFO BLOQ/SIN_PASS: " $1 }' /etc/shadow