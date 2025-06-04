#!/bin/bash
set -u # Tratar variables no seteadas como error

# Configuración
IP_SERVIDOR_BD="192.168.1.101" # <--- MODIFICAR ESTA IP si es necesario para el escaneo remoto

# Obtener información del sistema
FECHA_HORA=$(date +"%Y%m%d_%H%M%S")
NOMBRE_MAQUINA=$(hostname)
ID_MAQUINA=$(hostid 2>/dev/null || cat /etc/machine-id 2>/dev/null || echo "Desconocido")
USUARIO=$(whoami)

# Crear nombre de archivo de salida
ARCHIVO_SALIDA_DIR="./logs_auditoria"
mkdir -p "$ARCHIVO_SALIDA_DIR"
ARCHIVO_SALIDA="${ARCHIVO_SALIDA_DIR}/auditoria_${NOMBRE_MAQUINA}_${FECHA_HORA}.txt"

# Función para loguear mensajes SOLO al archivo
log_al_archivo() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$ARCHIVO_SALIDA"
}

# Función para loguear mensajes a pantalla Y al archivo
log_ambos() {
    local mensaje="$1"
    echo "$mensaje"
    log_al_archivo "$mensaje"
}

# Función para ejecutar un script y loguear su salida detallada al archivo,
# y un resumen en pantalla.
ejecutar_y_loguear_script() {
    local script_path="$1"
    local script_nombre=$(basename "$script_path")

    log_ambos ""
    log_ambos "============================================================"
    log_ambos "== Iniciando Script: $script_nombre"
    echo "Procesando $script_nombre... (ver $ARCHIVO_SALIDA para detalles)"

    log_al_archivo "---- INICIO SALIDA $script_nombre ----"
    # Ejecutar script y redirigir TODA su salida (stdout y stderr) al archivo de log
    if [[ "$script_nombre" == "01_escanear_puertos.sh" ]]; then
        bash "$script_path" "$IP_SERVIDOR_BD" >> "$ARCHIVO_SALIDA" 2>&1
    else
        bash "$script_path" >> "$ARCHIVO_SALIDA" 2>&1
    fi
    local exit_code=$?
    log_al_archivo "---- FIN SALIDA $script_nombre ----"
    
    if [ $exit_code -ne 0 ]; then
        log_ambos "AVISO: El script $script_nombre finalizó con código de error $exit_code."
    else
        log_ambos "== Script $script_nombre completado exitosamente."
    fi
    log_ambos "============================================================"
}

# Iniciar auditoría
echo "" > "$ARCHIVO_SALIDA" # Limpiar/crear archivo de log
log_ambos "############################################################"
log_ambos "###              INICIO DE AUDITORÍA DE SERVIDOR           ###"
log_ambos "############################################################"
log_al_archivo "Fecha y hora de inicio: $(date '+%Y-%m-%d %H:%M:%S %Z')"
log_al_archivo "Máquina local auditada: $NOMBRE_MAQUINA"
log_al_archivo "ID de máquina local: $ID_MAQUINA"
log_al_archivo "Usuario ejecutando auditoría: $USUARIO"
if [[ -n "$IP_SERVIDOR_BD" ]]; then
    log_al_archivo "IP del Servidor de Base de Datos (para escaneo remoto): $IP_SERVIDOR_BD"
fi
log_al_archivo "------------------------------------------------------------"

# Ejecutar cada script de auditoría en el directorio 'scripts'
for script in scripts/??_*.sh; do # Usar ??_* para asegurar orden y que sea un script
    if [ -f "$script" ]; then
        ejecutar_y_loguear_script "$script"
    fi
done

log_ambos ""
log_ambos "############################################################"
log_ambos "###             FIN DE AUDITORÍA DE SERVIDOR               ###"
log_ambos "############################################################"
log_al_archivo "Fecha y hora de finalización: $(date '+%Y-%m-%d %H:%M:%S %Z')"
log_ambos "Resultados completos guardados en: $(pwd)/$ARCHIVO_SALIDA"
log_ambos "############################################################"

echo ""
echo "Auditoría completada. Revisa el archivo: $(pwd)/$ARCHIVO_SALIDA para detalles."