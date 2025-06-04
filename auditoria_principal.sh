#!/bin/bash
set -u

IP_SERVIDOR_BD="192.168.1.101" # <--- MODIFICAR IP_SERVIDOR_BD

FECHA_HORA=$(date +"%Y%m%d_%H%M%S")
NOMBRE_MAQUINA=$(hostname)
ARCHIVO_SALIDA_DIR="./logs_auditoria"
mkdir -p "$ARCHIVO_SALIDA_DIR"
ARCHIVO_SALIDA="${ARCHIVO_SALIDA_DIR}/auditoria_${NOMBRE_MAQUINA}_${FECHA_HORA}.txt"

log_al_archivo() {
    echo "$(date '+%T') - $1" >> "$ARCHIVO_SALIDA"
}

ejecutar_script() {
    local script_path="$1"
    local script_nombre=$(basename "$script_path")
    local exit_code=0

    echo "Ejecutando: $script_nombre..." | tee -a "$ARCHIVO_SALIDA"
    log_al_archivo "--- INICIO $script_nombre ---"

    if [[ "$script_nombre" == "01_escanear_puertos.sh" ]]; then
        bash "$script_path" "$IP_SERVIDOR_BD" >> "$ARCHIVO_SALIDA" 2>&1
    else
        bash "$script_path" >> "$ARCHIVO_SALIDA" 2>&1
    fi
    exit_code=$?
    
    log_al_archivo "--- FIN $script_nombre (Salida: $exit_code) ---"
    
    if [ $exit_code -ne 0 ]; then
        echo "ERROR en $script_nombre (Salida: $exit_code). Ver log." | tee -a "$ARCHIVO_SALIDA"
    else
        echo "$script_nombre completado." | tee -a "$ARCHIVO_SALIDA"
    fi
    return $exit_code
}

# --- INICIO AUDITORÍA ---
echo "INICIO DE AUDITORÍA: $(date)" > "$ARCHIVO_SALIDA" # Sobrescribir/crear log
log_al_archivo "Máquina: $NOMBRE_MAQUINA, Usuario: $(whoami)"
if [[ -n "$IP_SERVIDOR_BD" ]]; then log_al_archivo "IP Servidor BD (Escaneo Remoto): $IP_SERVIDOR_BD"; fi

SCRIPTS_FALLIDOS=0
for script_file in scripts/??_*.sh; do
    if [ -f "$script_file" ]; then
        ejecutar_script "$script_file" || SCRIPTS_FALLIDOS=$((SCRIPTS_FALLIDOS + 1))
    fi
done

log_al_archivo "FIN DE AUDITORÍA: $(date)"
echo "Auditoría finalizada. Log: $ARCHIVO_SALIDA"
if [ $SCRIPTS_FALLIDOS -ne 0 ]; then echo "ATENCIÓN: $SCRIPTS_FALLIDOS script(s) fallaron."; fi