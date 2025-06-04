#!/bin/bash
ARCHIVOS_SENSIBLES=(
    "/etc/shadow:600"
    "/etc/gshadow:600" # Similar a shadow, pero para grupos
    "/etc/passwd:644"
    "/etc/group:644"
    "/root:700:d" # 'd' indica que es un directorio
)

echo "Revisando y ajustando permisos de archivos/directorios sensibles..."
echo "--------------------------------------------------------------------"

for item_perm in "${ARCHIVOS_SENSIBLES[@]}"; do
    IFS=':' read -r item perm tipo <<< "$item_perm"
    
    echo ""
    echo "Verificando: $item"
    if [ "$tipo" == "d" ]; then
        echo "Permisos actuales:"
        ls -ld "$item"
        echo "Ajustando permisos de $item a $perm (si es necesario)..."
        sudo chmod "$perm" "$item"
        echo "Permisos después del ajuste:"
        ls -ld "$item"
    else
        echo "Permisos actuales:"
        ls -l "$item"
        echo "Ajustando permisos de $item a $perm (si es necesario)..."
        sudo chmod "$perm" "$item"
        echo "Permisos después del ajuste:"
        ls -l "$item"
    fi
done
echo "--------------------------------------------------------------------"