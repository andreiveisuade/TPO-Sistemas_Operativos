#!/bin/bash
# Script para ajustar permisos en el SERVIDOR DE BASE DE DATOS
# ESTE SCRIPT SE EJECUTA COMO ROOT MEDIANTE "sudo bash -s" DESDE EL SCRIPT auditoria_fase2.sh
set -u
set -e

ARCHIVOS_SENSIBLES=(
    "/etc/shadow:600:f"
    "/etc/gshadow:600:f"
    "/etc/passwd:644:f"
    "/etc/group:644:f"
    "/root:700:d"
)

echo "=== AJUSTE DE PERMISOS EN SERVIDOR DE BASE DE DATOS ($(hostname)) ==="
echo "INFO: Ejecutando con privilegios de root."

for item_perm_tipo in "${ARCHIVOS_SENSIBLES[@]}"; do
    IFS=':' read -r item perm_deseado tipo <<< "$item_perm_tipo"
    
    if [ ! -e "$item" ]; then
        echo "AVISO: El archivo o directorio '$item' no existe. Saltando."
        continue
    fi
    
    perm_actual=$(stat -c "%a" "$item")
    echo "Verificando: $item (Actual: $perm_actual, Deseado: $perm_deseado)"

    if [ "$perm_actual" != "$perm_deseado" ]; then
        echo "  Ajustando permisos de $item de $perm_actual a $perm_deseado..."
        if chmod "$perm_deseado" "$item"; then # NO SUDO aquí
            echo "    Permisos ajustados."
        else
            echo "    ERROR: Falló el ajuste de permisos para $item."
        fi
    else
        echo "  Permisos para $item ya son correctos ($perm_actual)."
    fi
    
    if [ "$tipo" == "d" ]; then ls -ld "$item"; else ls -l "$item"; fi # NO SUDO aquí
    echo "---"
done
echo "Ajuste de permisos completado."