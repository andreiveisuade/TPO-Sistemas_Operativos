#!/bin/bash

# Este script debe ejecutarse desde el servidor workstation
# Su objetivo es ejecutar los scripts de endurecimiento (Fase 2) de forma remota en el servidor de base de datos

# Argumentos esperados:
# $1 = usuario remoto (por ejemplo: student)
# $2 = nombre o IP del servidor objetivo (por ejemplo: utility)
USER="$1"
TARGET="$2"

# Se crea una carpeta para guardar los logs si no existe
LOG_DIR="./logs_auditoria"
mkdir -p "$LOG_DIR"

# Se genera un nombre de archivo de log con la fecha actual
FECHA=$(date +"%Y%m%d_%H%M%S")
LOG="$LOG_DIR/fase2_$(hostname)_to_${TARGET}_$FECHA.log"

# Se registra el inicio de la auditoría en el log y en pantalla
echo "[+] Iniciando auditoria_fase2.sh" | tee -a "$LOG"

# Se define la lista de scripts a ejecutar en el servidor remoto
for s in 01_auditar_inicial_bd.sh 02_configurar_firewall.sh 03_ajustar_permisos.sh; do
  # Se informa qué script se va a ejecutar
  echo "[+] Ejecutando $s" | tee -a "$LOG"

  # 1. Se copia el script al servidor remoto (en /tmp)
  scp "./scripts/fase2/$s" "$USER@$TARGET:/tmp/$s"

  # 2. Se ejecuta el script de forma remota con sudo
  #    sudo podrá pedir la contraseña porque la sesión es interactiva
  # 3. Después de ejecutarlo, se elimina el script para limpiar el entorno
  ssh "$USER@$TARGET" "sudo bash /tmp/$s && rm /tmp/$s"
done

# Se registra el fin de la auditoría
echo "[+] Fin auditoria_fase2.sh" | tee -a "$LOG"