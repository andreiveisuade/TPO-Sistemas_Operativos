#!/bin/bash
set -u

# ===== FUNCIONES AUXILIARES =====
mostrar_ayuda() {
    echo "Uso: $0 <usuario_remoto> <ip_servidor_remoto>"
    echo "Ejemplo: $0 student utility"
    exit 1
}

# Validar parámetros
if [ $# -ne 2 ]; then
    echo "Error: Se requieren usuario remoto e IP del servidor remoto."
    mostrar_ayuda
fi

USUARIO_REMOTO="$1"
IP_SERVIDOR_REMOTO="$2"

# Validar formato de IP (solo verifica que tenga el formato básico)
if [[ ! $IP_SERVIDOR_REMOTO =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Error: El formato de la IP '$IP_SERVIDOR_REMOTO' no es válido."
    mostrar_ayuda
fi

# ===== CONFIGURACIÓN INICIAL =====
LOG_DIR="./logs_auditoria" # Mismo directorio de logs
mkdir -p "$LOG_DIR"
FECHA=$(date +"%Y%m%d_%H%M%S")
NOMBRE_MAQUINA_ACTUAL=$(hostname)
LOG="${LOG_DIR}/auditoria_Fase2_${NOMBRE_MAQUINA_ACTUAL}_on_${IP_SERVIDOR_REMOTO}_${FECHA}.txt"

DIR_SCRIPTS_FASE2_LOCAL="./scripts/fase2" # Scripts locales que se enviarán

# Iniciar el archivo de log
echo "INICIO DE AUDITORÍA (Fase 2 - Endurecimiento Remoto): $(date '+%Y-%m-%d %H:%M:%S %Z')" > "$LOG"
echo "Ejecutada desde: $NOMBRE_MAQUINA_ACTUAL" >> "$LOG"
echo "Servidor Objetivo para Endurecimiento: $IP_SERVIDOR_REMOTO" >> "$LOG"
echo "Usuario Remoto para ejecución: $USUARIO_REMOTO" >> "$LOG"
echo "NOTA: Se solicitará la contraseña de '$USUARIO_REMOTO' en '$IP_SERVIDOR_REMOTO' para los comandos sudo." >> "$LOG"
echo "----------------------------------------------------------" >> "$LOG"
echo "" >> "$LOG"

echo "=======================================================================" | tee -a "$LOG"
echo "=== INICIO DE FASE 2: Endurecimiento Remoto en $IP_SERVIDOR_REMOTO ===" | tee -a "$LOG"
echo "=======================================================================" | tee -a "$LOG"

SCRIPTS_A_EJECUTAR_REMOTO=(
    "${DIR_SCRIPTS_FASE2_LOCAL}/02_configurar_firewall.sh"
    "${DIR_SCRIPTS_FASE2_LOCAL}/03_ajustar_permisos.sh"
)
SCRIPTS_FALLIDOS=0

for script_local in "${SCRIPTS_A_EJECUTAR_REMOTO[@]}"; do
    script_nombre_remoto=$(basename "$script_local")
    echo "-----------------------------------------------------------------------" | tee -a "$LOG"
    echo "Ejecutando $script_nombre_remoto en $IP_SERVIDOR_REMOTO..." | tee -a "$LOG"
    
    if [ ! -f "$script_local" ]; then
        echo "ERROR: No se encontró el script local '$script_local'. Saltando." | tee -a "$LOG"
        SCRIPTS_FALLIDOS=$((SCRIPTS_FALLIDOS + 1))
        continue
    fi

    # El contenido del script local se pasa al stdin de 'sudo bash -s' en el host remoto
    # ssh -t fuerza la asignación de una pseudo-tty para que sudo pueda pedir contraseña
    # La salida del comando ssh (stdout y stderr del script remoto) se añade al log local
    if cat "$script_local" | ssh -t "$USUARIO_REMOTO@$IP_SERVIDOR_REMOTO" "sudo bash -s" >> "$LOG" 2>&1; then
        echo "$script_nombre_remoto ejecutado remotamente con éxito." | tee -a "$LOG"
    else
        # El código de salida de ssh podría no ser directamente el del script remoto si ssh mismo falla.
        # Pero si el script remoto falla (ej. exit 1), ssh debería propagar un código de error.
        echo "ERROR: Hubo un problema al ejecutar $script_nombre_remoto remotamente. Revisar log." | tee -a "$LOG"
        SCRIPTS_FALLIDOS=$((SCRIPTS_FALLIDOS + 1))
    fi
done

echo "-----------------------------------------------------------------------" | tee -a "$LOG"
echo "✅ Fase 2 de endurecimiento remoto (intentada) finalizada." | tee -a "$LOG"
echo "=======================================================================" | tee -a "$LOG"
echo "" >> "$LOG"
echo "FIN DE AUDITORÍA (Fase 2): $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "$LOG"
if [ $SCRIPTS_FALLIDOS -ne 0 ]; then
    echo "ATENCIÓN: La Fase 2 de auditoría finalizó con $SCRIPTS_FALLIDOS error(es)." | tee -a "$LOG"
fi
echo "Log de Fase 2 guardado en: $LOG"
echo "Auditoría Fase 2 completada. Ver resultados en: $LOG"
if [ $SCRIPTS_FALLIDOS -ne 0 ]; then echo "ATENCIÓN: Hubo errores durante la Fase 2."; fi

exit $SCRIPTS_FALLIDOS