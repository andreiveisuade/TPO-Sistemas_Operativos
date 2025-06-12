#!/bin/bash

# Activa el firewall y aplica una política estricta: solo lo esencial

echo "========== CONFIGURACIÓN DE FIREWALL =========="
echo "Hostname: $(hostname)"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"

# Asegura que firewalld esté activo (ignora si ya lo está)
systemctl enable --now firewalld > /dev/null 2>&1

# Elimina servicios innecesarios conocidos
firewall-cmd --permanent --remove-service=http > /dev/null 2>&1
firewall-cmd --permanent --remove-service=https > /dev/null 2>&1
firewall-cmd --permanent --remove-service=cockpit > /dev/null 2>&1
firewall-cmd --permanent --remove-service=dhcpv6-client > /dev/null 2>&1

# Elimina puertos abiertos inesperadamente
firewall-cmd --permanent --remove-port=8443/tcp > /dev/null 2>&1

# Agrega solo lo necesario
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port=3306/tcp

# Aplica los cambios
firewall-cmd --reload

# Muestra configuración final
firewall-cmd --list-all