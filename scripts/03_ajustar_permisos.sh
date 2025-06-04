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
    IFS=':' read -r item perm_deseado tipo <<< "$item_perm"
    echo "Ajustando $item a $perm_deseado..."
    sudo chmod "$perm_deseado" "$item" || echo "ERROR ajustando $item"
    if [ "$tipo" == "d" ]; then ls -ld "$item"; else ls -l "$item"; fi
done