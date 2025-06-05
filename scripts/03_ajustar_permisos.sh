#!/bin/bash
set -u

ARCHIVOS_SENSIBLES=(
    "/etc/shadow:600"
    "/etc/gshadow:600"
    "/etc/passwd:644"
    "/etc/group:644"
    "/root:700:d"
)

echo "Ajustando permisos críticos..."

for item_perm in "${ARCHIVOS_SENSIBLES[@]}"; do
    IFS=':' read -ra permisos <<< "$item_perm"
    item="${permisos[0]}"
    perm_deseado="${permisos[1]}"
    tipo="${permisos[2]:-f}"

    echo "Ajustando $item a $perm_deseado..."
    sudo chmod "$perm_deseado" "$item" || echo "ERROR ajustando $item"

    case "$tipo" in
        d) ls -ld "$item" ;;
        f) ls -l "$item" ;;
        *) echo "ERROR: tipo de archivo desconocido para $item" ;;
    esac
done