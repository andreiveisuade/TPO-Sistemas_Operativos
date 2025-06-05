#!/bin/bash
set -u

# ===== FUNCIONES AUXILIARES =====
mostrar_ayuda() {
    echo "Uso: $0 <ip_servidor_objetivo>"
    echo "Ejemplo: $0 192.168.1.100"
    exit 1
}

# Validar parámetros
if [ $# -ne 1 ]; then
    echo "Error: Se requiere la dirección IP del servidor objetivo como parámetro."
    mostrar_ayuda
fi

IP_SERVIDOR_OBJETIVO="$1" # Renombrado para más claridad

if [[ ! $IP_SERVIDOR_OBJETIVO =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Error: El formato de la IP '$IP_SERVIDOR_OBJETIVO' no es válido."
    mostrar_ayuda
fi

# ===== CONFIGURACIÓN INICIAL =====
LOG_DIR="./logs_auditoria"
mkdir -p "$LOG_DIR"
FECHA=$(date +"%Y%m%d_%H%M%S")
NOMBRE_MAQUINA_ACTUAL=$(hostname) # Máquina desde donde se ejecuta la auditoría
LOG="${LOG_DIR}/auditoria_Fase1_${NOMBRE_MAQUINA_ACTUAL}_to_${IP_SERVIDOR_OBJETIVO}_${FECHA}.txt"

# Iniciar el archivo de log
echo "INICIO DE AUDITORÍA (Fase 1 - Escaneo Remoto): $(date '+%Y-%m-%d %H:%M:%S %Z')" > "$LOG"
echo "Ejecutada desde: $NOMBRE_MAQUINA_ACTUAL" >> "$LOG"
echo "Servidor Objetivo: $IP_SERVIDOR_OBJETIVO" >> "$LOG"
echo "----------------------------------------------------------" >> "$LOG"
echo "" >> "$LOG"

# ===== EJECUCIÓN DE SCRIPTS DE AUDITORÍA =====
SCRIPTS_DIR_FASE1="./scripts/fase1"
if [ ! -d "$SCRIPTS_DIR_FASE1" ]; then
    echo "Error: No se encontró el directorio de scripts '$SCRIPTS_DIR_FASE1'" | tee -a "$LOG"
    exit 1
fi

SCRIPT_ESCANEAR="${SCRIPTS_DIR_FASE1}/01_escanear.sh"
SCRIPTS_FALLIDOS=0

if [ -f "$SCRIPT_ESCANEAR" ]; then
    echo "== Ejecutando $(basename "$SCRIPT_ESCANEAR") para $IP_SERVIDOR_OBJETIVO ==" | tee -a "$LOG"
    # Ejecutar script y redirigir toda su salida al log
    bash "$SCRIPT_ESCANEAR" "$IP_SERVIDOR_OBJETIVO" >> "$LOG" 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR al ejecutar $(basename "$SCRIPT_ESCANEAR")" | tee -a "$LOG"
        SCRIPTS_FALLIDOS=1
    else
        echo "$(basename "$SCRIPT_ESCANEAR") completado" | tee -a "$LOG"
    fi
    echo "" >> "$LOG"
else
    echo "Advertencia: No se encontró el script $SCRIPT_ESCANEAR" | tee -a "$LOG"
    SCRIPTS_FALLIDOS=1
fi

# ===== FINALIZACIÓN =====
echo "----------------------------------------------------------" >> "$LOG"
echo "FIN DE AUDITORÍA (Fase 1): $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "$LOG"
if [ $SCRIPTS_FALLIDOS -ne 0 ]; then
    echo "ATENCIÓN: La Fase 1 de auditoría finalizó con errores." | tee -a "$LOG"
fi
echo "Log de Fase 1 guardado en: $LOG"
echo "Auditoría Fase 1 completada. Ver resultados en: $LOG"
if [ $SCRIPTS_FALLIDOS -ne 0 ]; then echo "ATENCIÓN: Hubo errores durante la Fase 1."; fi

exit $SCRIPTS_FALLIDOS