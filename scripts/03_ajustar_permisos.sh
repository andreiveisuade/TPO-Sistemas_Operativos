#!/bin/bash
# set -e
set -u

ARCHIVOS_SENSIBLES=(
    "/etc/shadow:600"
    "/etc/gshadow:600"
    "/etc/passwd:644"
    "/etc/group:644"
    "/root:700:d"
)

echo "INFO: Iniciando revisión y ajuste de permisos de archivos/directorios sensibles."

for item_perm in "${ARCHIVOS_SENSIBLES[@]}"; do
    IFS=':' read -r item perm_deseado tipo <<< "$item_perm"
    
    echo "--- Verificando: $item ---"
    if [ "$tipo" == "d" ]; then
        perm_actual=$(stat -c "%a" "$item")
        ls -ld "$item" # Muestra permisos actuales
    else
        perm_actual=$(stat -c "%a" "$item")
        ls -l "$item" # Muestra permisos actuales
    fi

    if [ "$perm_actual" != "$perm_deseado" ]; then
        echo "INFO: Ajustando permisos de $item de $perm_actual a $perm_deseado..."
        if sudo chmod "$perm_deseado" "$item"; then
            echo "INFO: Permisos ajustados para $item."
            # Mostrar permisos después del ajuste
            if [ "$tipo" == "d" ]; then ls -ld "$item"; else ls -l "$item"; fi
        else
            echo "ERROR: Falló el ajuste de permisos para $item."
        fi
    else
        echo "INFO: Permisos para $item ya son correctos ($perm_actual)."
    fi
done
echo "--------------------------------------------------------------------"