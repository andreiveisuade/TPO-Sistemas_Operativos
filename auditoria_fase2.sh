
#!/bin/bash
# Script a ejecutar en WORKSTATION para ejecutar scripts de endurecimiento en un SERVIDOR REMOTO (BD)
set -u

USUARIO_REMOTO="$1"
MAQUINA_TARGET="$2"

LOG_DIR="./logs_auditoria"
mkdir -p "$LOG_DIR"
FECHA=$(date +"%Y%m%d_%H%M%S")
MAQUINA_ACTUAL=$(hostname)
LOG="${LOG_DIR}/auditoria_Fase2_${MAQUINA_ACTUAL}_on_${MAQUINA_TARGET}_${FECHA}.txt"

DIR_SCRIPTS_FASE2_LOCAL="./scripts/fase2"

echo "INICIO DE AUDITORÍA (Fase 2 - Endurecimiento Remoto): $(date '+%Y-%m-%d %H:%M:%S %Z')" > "$LOG"
echo "Ejecutada desde: $MAQUINA_ACTUAL" >> "$LOG"
echo "Servidor Objetivo para Endurecimiento: $MAQUINA_TARGET" >> "$LOG"
echo "Usuario Remoto para ejecución: $USUARIO_REMOTO" >> "$LOG"
echo "NOTA: Se solicitará la contraseña de '$USUARIO_REMOTO' en '$MAQUINA_TARGET' para los comandos sudo." >> "$LOG"
echo "----------------------------------------------------------" >> "$LOG"
echo "" >> "$LOG"

echo "=======================================================================" | tee -a "$LOG"
echo "=== INICIO DE FASE 2: Endurecimiento Remoto en $MAQUINA_TARGET ===" | tee -a "$LOG"
echo "=======================================================================" | tee -a "$LOG"

SCRIPTS_A_EJECUTAR_REMOTO=(
    "${DIR_SCRIPTS_FASE2_LOCAL}/01_auditar_inicial_bd.sh" # Nuevo script para checks iniciales en BD
    "${DIR_SCRIPTS_FASE2_LOCAL}/02_configurar_firewall.sh"
    "${DIR_SCRIPTS_FASE2_LOCAL}/03_ajustar_permisos.sh"
)
SCRIPTS_FALLIDOS=0

for script_local in "${SCRIPTS_A_EJECUTAR_REMOTO[@]}"; do
    script_nombre_remoto=$(basename "$script_local")
    echo "-----------------------------------------------------------------------" | tee -a "$LOG"
    echo "Ejecutando $script_nombre_remoto en $MAQUINA_TARGET..." | tee -a "$LOG"
    
    if [ ! -f "$script_local" ]; then
        echo "ERROR: No se encontró el script local '$script_local'. Saltando." | tee -a "$LOG"
        SCRIPTS_FALLIDOS=$((SCRIPTS_FALLIDOS + 1))
        continue
    fi

    # Se pasa el contenido del script local al stdin de 'sudo bash -s' en el host remoto
    # ssh -t es esencial para que sudo pueda pedir la contraseña
    echo "  (Salida del script remoto será logueada en $LOG)" | tee -a "$LOG"
    if cat "$script_local" | ssh -t "$USUARIO_REMOTO@$MAQUINA_TARGET" "sudo bash -s" >> "$LOG" 2>&1; then
        echo "  $script_nombre_remoto ejecutado remotamente con éxito." | tee -a "$LOG"
    else
        echo "  ERROR: Hubo un problema al ejecutar $script_nombre_remoto remotamente. Revisar log." | tee -a "$LOG"
        SCRIPTS_FALLIDOS=$((SCRIPTS_FALLIDOS + 1))
    fi
done

echo "-----------------------------------------------------------------------" | tee -a "$LOG"
echo "✅ Fase 2 de endurecimiento intentada finalizada." | tee -a "$LOG"
echo "=======================================================================" | tee -a "$LOG"
echo "" >> "$LOG"
echo "FIN DE AUDITORÍA (Fase 2): $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "$LOG"
if [ $SCRIPTS_FALLIDOS -ne 0 ]; then
    echo "ATENCIÓN: La Fase 2 de auditoría finalizó con $SCRIPTS_FALLIDOS error(es)." | tee -a "$LOG"
fi
echo "Log de Fase 2 guardado en: $LOG" | tee -a "$LOG"
echo "Auditoría Fase 2 completada. Ver resultados en: $LOG"
if [ $SCRIPTS_FALLIDOS -ne 0 ]; then echo "ATENCIÓN: Hubo errores durante la Fase 2."; fi

exit $SCRIPTS_FALLIDOS