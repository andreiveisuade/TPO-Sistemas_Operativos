#!/bin/bash
set -u

USER="$1"
TARGET="$2"
FECHA=$(date +"%Y%m%d_%H%M%S")
HOST=$(hostname)
LOG_DIR="./logs_auditoria"
mkdir -p "$LOG_DIR"
LOG="${LOG_DIR}/fase2_${HOST}_to_${TARGET}_${FECHA}.log"

SCRIPTS=(01_auditar_inicial_bd.sh 02_configurar_firewall.sh 03_ajustar_permisos.sh)

for script in "${SCRIPTS[@]}"; do
  PATH_LOCAL="./scripts/fase2/$script"
  [[ -f "$PATH_LOCAL" ]] || { echo "No existe $PATH_LOCAL"; continue; }

  echo "[+] Ejecutando $script en $TARGET" | tee -a "$LOG"
  ssh -t "$USER@$TARGET" "sudo bash -s" < "$PATH_LOCAL" >> "$LOG" 2>&1 \
    && echo "[OK] $script" | tee -a "$LOG" \
    || echo "[ERROR] $script" | tee -a "$LOG"
done