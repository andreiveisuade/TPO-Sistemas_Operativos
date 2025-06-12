#!/bin/bash
# Script a ejecutar en WORKSTATION para ejecutar scripts de endurecimiento en un SERVIDOR REMOTO (BD)
set -u

# --- Verificación de argumentos ---
if [ "$#" -ne 2 ]; then
    echo "ERROR: Se requieren dos argumentos." >&2
    echo "Uso: $0 <usuario_remoto> <maquina_objetivo>" >&2
    exit 1
fi

USUARIO_REMOTO="$1"
MAQUINA_TARGET="$2"

# --- NUEVO: Pedir la contraseña de forma segura UNA SOLA VEZ al inicio ---
# El flag -s (silent) oculta la contraseña mientras se escribe.
echo -n "Introduce la contraseña para '$USUARIO_REMOTO' en '$MAQUINA_TARGET': "
read -s USUARIO_PASSWORD
echo # Añade un salto de línea para que la siguiente salida no se pegue.

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
# NOTA: Ya no se pide la contraseña en cada paso, sino al principio.
echo "----------------------------------------------------------" >> "$LOG"
echo "" >> "$LOG"

echo "=======================================================================" | tee -a "$LOG"
echo "=== INICIO DE FASE 2: Endurecimiento Remoto en $MAQUINA_TARGET ===" | tee -a "$LOG"
echo "=======================================================================" | tee -a "$LOG"

SCRIPTS_A_EJECUTAR_REMOTO=(
    "${DIR_SCRIPTS_FASE2_LOCAL}/01_auditar_inicial_bd.sh"
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

    # --- LÍNEA MODIFICADA: La lógica de ejecución ha cambiado por completo ---
    # 1. 'echo "$USUARIO_PASSWORD"' envía la contraseña guardada.
    # 2. Se la pasamos por un "pipe" a ssh.
    # 3. 'ssh' ejecuta 'sudo -S' que lee la contraseña del pipe.
    # 4. 'sudo -S' ejecuta 'bash -s' que a su vez lee el script de 'cat'.
    # 5. El flag -t ya NO es necesario, porque este método es no-interactivo por diseño.
    echo "  (Salida del script remoto será logueada en $LOG)" | tee -a "$LOG"
    if echo "$USUARIO_PASSWORD" | ssh "$USUARIO_REMOTO@$MAQUINA_TARGET" "sudo -S bash -s" < "$script_local" >> "$LOG" 2>&1; then
        echo "  $script_nombre_remoto ejecutado remotamente con éxito." | tee -a "$LOG"
    else
        echo "  ERROR: Hubo un problema al ejecutar $script_nombre_remoto remotamente. Revisar log." | tee -a "$LOG"
        SCRIPTS_FALLIDOS=$((SCRIPTS_FALLIDOS + 1))
    fi
done

# --- Limpiar la variable de la contraseña de la memoria ---
unset USUARIO_PASSWORD

echo "-----------------------------------------------------------------------" | tee -a "$LOG"
echo "✅ Fase 2 de endurecimiento remoto (intentada) finalizada." | tee -a "$LOG"
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