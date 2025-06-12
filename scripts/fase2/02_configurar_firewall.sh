#!/bin/bash

# Activa el firewall y aplica una política estricta: solo lo esencial.

echo "========== CONFIGURACIÓN DE FIREWALL =========="
echo "Hostname: $(hostname)"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"

# Asegura que firewalld esté activo, pero no da error si ya lo estaba.
systemctl enable --now firewalld > /dev/null 2>&1

# Eliminar servicios innecesarios

# Basado en el hallazgo de Fase 1, cerramos explícitamente http/https.
firewall-cmd --permanent --remove-service=http > /dev/null 2>&1
firewall-cmd --permanent --remove-service=https > /dev/null 2>&1

# Añadir solo los servicios/puertos requeridos
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port=3306/tcp

# Recargar para aplicar todos los cambios
firewall-cmd --reload

# Mostrar configuración final
firewall-cmd --list-all