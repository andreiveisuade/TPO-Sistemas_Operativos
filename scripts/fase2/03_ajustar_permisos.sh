#!/bin/bash

# Ajusta permisos de archivos y directorios críticos.

# Permisos para archivos de contraseñas y configuración de BD
chmod 600 /etc/shadow /etc/gshadow /etc/my.cnf

# Permisos para archivos de usuarios/grupos
chmod 644 /etc/passwd /etc/group

# Permisos para directorios sensibles (root y datos de BD)
chmod 700 /root /var/lib/mysql