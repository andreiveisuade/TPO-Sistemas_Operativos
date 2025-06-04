#!/bin/bash

# Configuración
IP_SERVIDOR_BD="192.168.1.101" # <--- MODIFICAR ESTA IP si es necesario para el escaneo remoto

# Obtener información del sistema
FECHA_HORA=$(date +"%Y%m%d_%H%M%S")
NOMBRE_MAQUINA=$(hostname)
ID_MAQUINA=$(hostid 2>/dev/null || cat /etc/machine-id 2>/dev/null || echo "Desconocido") # Intentar alternativas para hostid
USUARIO=$(whoami)

# Crear nombre de archivo de salida
ARCHIVO_SALIDA_DIR="./logs_auditoria"
mkdir -p "$ARCHIVO_SALIDA_DIR"
ARCHIVO_SALIDA="${ARCHIVO_SALIDA_DIR}/auditoria_${NOMBRE_MAQUINA}_${FECHA_HORA}.txt"

# Función para mostrar mensajes tanto en pantalla como en el archivo de log
log_mensaje() {
    echo "$1" | tee -a "$ARCHIVO_SALIDA"
}

# Función para ejecutar un script y loguear su salida
ejecutar_y_loguear_script() {
    local script_path="$1"
    local script_nombre=$(basename "$script_path")

    log_mensaje ""
    log_mensaje "============================================================"
    log_mensaje "== Ejecutando Script: $script_nombre"
    log_mensaje "============================================================"
    
    # Pasar IP_SERVIDOR_BD como argumento si el script lo necesita (ej. escanear_puertos.sh)
    if [[ "$script_nombre" == "escanear_puertos.sh" ]]; then
        bash "$script_path" "$IP_SERVIDOR_BD" 2>&1 | tee -a "$ARCHIVO_SALIDA"
    else
        bash "$script_path" 2>&1 | tee -a "$ARCHIVO_SALIDA"
    fi
    
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_mensaje "AVISO: El script $script_nombre finalizó con código de error $exit_code."
    fi
    log_mensaje "== Fin de ejecución: $script_nombre =="
}

# Iniciar auditoría
echo "" > "$ARCHIVO_SALIDA" # Limpiar/crear archivo de log
log_mensaje "############################################################"
log_mensaje "###              INICIO DE AUDITORÍA DE SERVIDOR           ###"
log_mensaje "############################################################"
log_mensaje "Fecha y hora de inicio: $(date '+%Y-%m-%d %H:%M:%S %Z')"
log_mensaje "Máquina local auditada: $NOMBRE_MAQUINA"
log_mensaje "ID de máquina local: $ID_MAQUINA"
log_mensaje "Usuario ejecutando auditoría: $USUARIO"
if [[ -n "$IP_SERVIDOR_BD" ]]; then
    log_mensaje "IP del Servidor de Base de Datos (para escaneo remoto): $IP_SERVIDOR_BD"
fi
log_mensaje "------------------------------------------------------------"

# Ejecutar cada script de auditoría en el directorio 'scripts'
# Se ejecutan en orden alfabético. Si se requiere un orden específico, nombrarlos con prefijos (01_, 02_, etc.)
for script in scripts/*.sh; do
    if [ -f "$script" ]; then # Asegurarse que es un archivo
        ejecutar_y_loguear_script "$script"
    fi
done

log_mensaje ""
log_mensaje "############################################################"
log_mensaje "###             FIN DE AUDITORÍA DE SERVIDOR               ###"
log_mensaje "############################################################"
log_mensaje "Fecha y hora de finalización: $(date '+%Y-%m-%d %H:%M:%S %Z')"
log_mensaje "Resultados completos guardados en: $(pwd)/$ARCHIVO_SALIDA"
log_mensaje "############################################################"

echo ""
echo "Auditoría completada. Revisa el archivo: $(pwd)/$ARCHIVO_SALIDA"