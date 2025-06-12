#!/bin/bash

# Ajusta permisos de archivos y directorios críticos

echo "========== AJUSTE DE PERMISOS =========="
echo "Hostname: $(hostname)"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"

# Archivos sensibles
chmod 600 /etc/shadow /etc/gshadow 2>/dev/null
chmod 644 /etc/passwd /etc/group 2>/dev/null

# Directorios críticos
chmod 700 /root /var/lib/mysql 2>/dev/null

# Configuración de base de datos si existe
[[ -f /etc/my.cnf ]] && chmod 600 /etc/my.cnf