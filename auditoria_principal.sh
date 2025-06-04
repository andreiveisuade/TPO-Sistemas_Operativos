#!/bin/bash
# Script principal de auditoría de sistemas
# Realiza una serie de comprobaciones de seguridad ejecutando scripts en el directorio scripts/
# Genera un archivo de log con los resultados de todas las auditorías realizadas

# Configuración de seguridad: sale si hay variables sin inicializar
set -u

# Configuración de la IP del servidor de base de datos
# IMPORTANTE: El usuario debe modificar esta variable con la IP correcta
IP_SERVIDOR_BD="192.168.1.101" # <--- MODIFICAR IP_SERVIDOR_BD

# Configuración de nombres de archivos y directorios
FECHA_HORA=$(date +"%Y%m%d_%H%M%S")  # Obtiene la fecha y hora actual formateada
NOMBRE_MAQUINA=$(hostname)           # Obtiene el nombre del host actual
ARCHIVO_SALIDA_DIR="./logs_auditoria" # Directorio donde se guardarán los logs
mkdir -p "$ARCHIVO_SALIDA_DIR"        # Crea el directorio de logs si no existe
# Nombre del archivo de salida con formato: auditoria_[nombre_maquina]_[fecha_hora].txt
ARCHIVO_SALIDA="${ARCHIVO_SALIDA_DIR}/auditoria_${NOMBRE_MAQUINA}_${FECHA_HORA}.txt"

# Función para registrar mensajes en el archivo de log
# Parámetros:
#   $1: Mensaje a registrar
log_al_archivo() {
    echo "$(date '+%T') - $1" >> "$ARCHIVO_SALIDA"
}

# Función para ejecutar un script de auditoría
# Parámetros:
#   $1: Ruta al script a ejecutar
ejecutar_script() {
    local script_path="$1"
    local script_nombre=$(basename "$script_path")  # Obtiene solo el nombre del archivo
    local exit_code=0

    # Muestra y registra el inicio de la ejecución del script
    echo "Ejecutando: $script_nombre..." | tee -a "$ARCHIVO_SALIDA"
    log_al_archivo "--- INICIO $script_nombre ---"

    # Ejecuta el script con manejo especial para el escaneo de puertos
    if [[ "$script_nombre" == "01_escanear_puertos.sh" ]]; then
        # Pasa la IP del servidor de BD como argumento solo al script de escaneo de puertos
        bash "$script_path" "$IP_SERVIDOR_BD" >> "$ARCHIVO_SALIDA" 2>&1
    else
        # Ejecuta otros scripts sin argumentos adicionales
        bash "$script_path" >> "$ARCHIVO_SALIDA" 2>&1
    fi
    exit_code=$?  # Captura el código de salida del script ejecutado
    
    # Registra la finalización del script con su código de salida
    log_al_archivo "--- FIN $script_nombre (Salida: $exit_code) ---"
    
    # Muestra mensaje de error si el script falló
    if [ $exit_code -ne 0 ]; then
        echo "ERROR en $script_nombre (Salida: $exit_code). Ver log." | tee -a "$ARCHIVO_SALIDA"
    else
        echo "$script_nombre completado." | tee -a "$ARCHIVO_SALIDA"
    fi
    return $exit_code
}

# --- INICIO DE LA EJECUCIÓN PRINCIPAL ---

# Inicializa el archivo de log con la fecha y hora de inicio
echo "INICIO DE AUDITORÍA: $(date)" > "$ARCHIVO_SALIDA" # Sobrescribe el archivo de log

# Registra información básica del sistema
log_al_archivo "Máquina: $NOMBRE_MAQUINA, Usuario: $(whoami)"

# Registra la IP del servidor de BD si está configurada
if [[ -n "$IP_SERVIDOR_BD" ]]; then 
    log_al_archivo "IP Servidor BD (Escaneo Remoto): $IP_SERVIDOR_BD"; 
fi

# Contador para scripts que fallen
SCRIPTS_FALLIDOS=0

# Itera sobre todos los scripts en el directorio scripts/ que sigan el patrón ??_*.sh
# Los scripts se ejecutarán en orden alfabético
for script_file in scripts/??_*.sh; do
    if [ -f "$script_file" ]; then  # Verifica que el archivo exista
        # Ejecuta el script y cuenta los fallos
        ejecutar_script "$script_file" || SCRIPTS_FALLIDOS=$((SCRIPTS_FALLIDOS + 1))
    fi
done

# Registra la finalización de la auditoría
log_al_archivo "FIN DE AUDITORÍA: $(date)"

# Muestra el resumen de la ejecución
echo "Auditoría finalizada. Log: $ARCHIVO_SALIDA"
if [ $SCRIPTS_FALLIDOS -ne 0 ]; then 
    echo "ATENCIÓN: $SCRIPTS_FALLIDOS script(s) fallaron."
fi