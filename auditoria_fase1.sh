#!/bin/bash
# Usamos bash como intérprete del script

set -u
# Hace que el script termine si se usa una variable no definida (mejor para evitar errores silenciosos)

MAQUINA_TARGET="$1"


LOG_DIR="./logs_auditoria"
# Directorio donde se guardarán los archivos de log

mkdir -p "$LOG_DIR"
FECHA=$(date +"%Y%m%d_%H%M%S")
MAQUINA_ACTUAL=$(hostname)
LOG="${LOG_DIR}/auditoria_Fase1_${MAQUINA_ACTUAL}_to_${MAQUINA_TARGET}_${FECHA}.txt"

# Inicio de auditoría
echo "INICIO DE AUDITORÍA (Fase 1 - Escaneo Remoto): $(date '+%Y-%m-%d %H:%M:%S %Z')" > "$LOG"
echo "Ejecutada desde: $MAQUINA_ACTUAL" >> "$LOG"
echo "Servidor de Base de Datos Objetivo: $MAQUINA_TARGET" >> "$LOG"
echo "----------------------------------------------------------" >> "$LOG"
echo "" >> "$LOG"

SCRIPTS_DIR_FASE1="./scripts/fase1"
# Carpeta donde se encuentran los scripts de la fase 1 de auditoría

SCRIPT_ESCANEAR="${SCRIPTS_DIR_FASE1}/01_escanear.sh"
# Ruta completa al script de escaneo remoto

# Verificar si el script de escaneo existe
if [ ! -f "$SCRIPT_ESCANEAR" ]; then
    echo "ERROR: No se encontró el script de escaneo de Fase 1: '$SCRIPT_ESCANEAR'" | tee -a "$LOG" >&2
    echo "FIN DE AUDITORÍA (Fase 1) con error." | tee -a "$LOG" >&2
    exit 1
fi


echo "== Ejecutando $(basename "$SCRIPT_ESCANEAR") para $MAQUINA_TARGET ==" | tee -a "$LOG"
# Imprime y registra en el log qué script se está ejecutando y para qué máquina

# Ejecuta el script de escaneo y guarda toda su salida (stdout + stderr) en el log
# tee -a aquí para que la salida también se muestre en la consola
if bash "$SCRIPT_ESCANEAR" "$MAQUINA_TARGET" | tee -a "$LOG"; then
    echo "$(basename "$SCRIPT_ESCANEAR") finalizado con éxito." | tee -a "$LOG"
    exit 0
else
    echo "$(basename "$SCRIPT_ESCANEAR") finalizó con errores. Revisar log." | tee -a "$LOG" >&2
    exit 1
fi


echo "" >> "$LOG"
echo "----------------------------------------------------------" >> "$LOG"
echo -e "FIN DE AUDITORÍA (Fase 1): $(date '+%Y-%m-%d %H:%M:%S %Z')\nLog de Fase 1 guardado en: $LOG\nAuditoría Fase 1 completada. Ver resultados en: $LOG" | tee -a "$LOG"