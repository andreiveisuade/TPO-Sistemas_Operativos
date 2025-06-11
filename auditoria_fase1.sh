#!/bin/bash
set -u

TARGET="$1"
FECHA=$(date +"%Y%m%d_%H%M%S")
HOST=$(hostname)
LOG_DIR="./logs_auditoria"
mkdir -p "$LOG_DIR"
LOG="${LOG_DIR}/fase1_${HOST}_to_${TARGET}_${FECHA}.log"

SCRIPT="./scripts/fase1/01_escanear.sh"
[[ -f "$SCRIPT" ]] || { echo "No existe $SCRIPT"; exit 1; }

echo "[+] Ejecutando escaneo remoto a $TARGET desde $HOST" | tee "$LOG"
bash "$SCRIPT" "$TARGET" | tee -a "$LOG"