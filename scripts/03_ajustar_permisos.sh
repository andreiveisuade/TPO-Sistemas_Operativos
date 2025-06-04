#!/bin/bash
# Script para ajustar permisos de archivos y directorios críticos
# Asegura que los archivos sensibles tengan los permisos correctos

# Configuración de seguridad: falla si hay variables no definidas
set -u

# Array que contiene los archivos/directorios sensibles y sus permisos deseados
# Formato: "ruta:permisos:tipo" donde:
#   - permisos: 3 dígitos (propietario, grupo, otros)
#     - 4 = lectura (r--), 2 = escritura (-w-), 1 = ejecución (--x)
#     - Ej: 6 = 4+2 (lectura+escritura), 5 = 4+1 (lectura+ejecución)
#   - tipo: 'd' para directorio o 'f' para archivo
ARCHIVOS_SENSIBLES=(
    # Archivo de contraseñas encriptadas (solo root debe acceder)
    # -rw------- (600): propietario: lectura+escritura, grupo: nada, otros: nada
    "/etc/shadow:600"

    # Archivo de contraseñas de grupos (solo root debe acceder)
    # -rw------- (600): propietario: lectura+escritura, grupo: nada, otros: nada
    "/etc/gshadow:600"

    # Archivo de información de usuarios
    # -rw-r--r-- (644): propietario: lectura+escritura, grupo: lectura, otros: lectura
    "/etc/passwd:644"

    # Archivo de información de grupos
    # -rw-r--r-- (644): propietario: lectura+escritura, grupo: lectura, otros: lectura
    "/etc/group:644"

    # Directorio home del usuario root
    # drwx------ (700): propietario: todo (lectura+escritura+ejecución), grupo: nada, otros: nada
    # 'd' indica que es un directorio
    "/root:700:d"
)

echo "Ajustando permisos críticos..."

# Itera sobre cada elemento del array ARCHIVOS_SENSIBLES
for item_perm in "${ARCHIVOS_SENSIBLES[@]}"; do
    # Divide la cadena en un array usando ':' como delimitador
    IFS=':' read -ra permisos <<< "$item_perm"
    
    # Extrae los componentes de la ruta, permisos y tipo
    item="${permisos[0]}"          # Ruta del archivo/directorio
    perm_deseado="${permisos[1]}"   # Permisos a aplicar (ej: 600, 644, 700)
    tipo="${permisos[2]:-f}"        # Tipo: 'd' para directorio, 'f' para archivo (por defecto)
    
    # Muestra el archivo/directorio que se está procesando
    echo "Ajustando $item a $perm_deseado..."
    
    # Intenta cambiar los permisos, muestra error si falla
    sudo chmod "$perm_deseado" "$item" || echo "ERROR ajustando $item"
    
    # Muestra los permisos resultantes según el tipo
    case "$tipo" in
        d) ls -ld "$item" ;;        # Muestra información detallada para directorios
        f) ls -l "$item" ;;         # Muestra información detallada para archivos
        *) echo "ERROR: tipo de archivo desconocido para $item" ;;  # Manejo de error
    esac
done