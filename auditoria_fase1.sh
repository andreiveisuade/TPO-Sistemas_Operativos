#!/bin/bash

# Argumento: IP o hostname de la máquina a auditar
MAQUINA_TARGET="$1"

# Carpeta y archivo de log
LOG_DIR="./logs_auditoria"
mkdir -p "$LOG_DIR"
FECHA=$(date +"%Y%m%d_%H%M%S")
LOG="$LOG_DIR/auditoria_Fase1_$(hostname)_to_${MAQUINA_TARGET}_$FECHA.txt"

echo "[+] Iniciando auditoria_fase1.sh" | tee -a "$LOG"

# Ejecuta el script de escaneo y guarda salida en el log
bash ./scripts/fase1/01_escanear.sh "$MAQUINA_TARGET" | tee -a "$LOG"

echo "[+] Fin auditoria_fase1.sh" | tee -a "$LOG"