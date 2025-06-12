#!/bin/bash

# Argumentos: usuario SSH y máquina destino
USER="$1"
TARGET="$2"

# Carpeta y archivo de log
LOG_DIR="./logs_auditoria"
mkdir -p "$LOG_DIR"
FECHA=$(date +"%Y%m%d_%H%M%S")
LOG="$LOG_DIR/fase2_$(hostname)_to_${TARGET}_$FECHA.log"

echo "[+] Iniciando auditoria_fase2.sh" | tee -a "$LOG"

# Ejecuta los scripts de endurecimiento en el servidor remoto
for s in 01_auditar_inicial_bd.sh 02_configurar_firewall.sh 03_ajustar_permisos.sh; do
  echo "[+] Ejecutando $s" | tee -a "$LOG"
  ssh -t "$USER@$TARGET" "sudo bash -s" < "./scripts/fase2/$s" | tee -a "$LOG"
done

echo "[+] Fin auditoria_fase2.sh" | tee -a "$LOG"