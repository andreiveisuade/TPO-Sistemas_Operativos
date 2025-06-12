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

# Pedir la contraseña una sola vez
echo -n "Ingrese la contraseña de sudo para $USER@$TARGET: "
read -s SUDO_PASS
echo

# Encabezado del log para dejar bien marcado el inicio de la auditoría
{
  echo "=================================================="
  echo "=== AUDITORÍA FASE 2: Endurecimiento del sistema ==="
  echo "Target: $TARGET"
  echo "Usuario: $USER"
  echo "Fecha de ejecución: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "=================================================="
  echo ""
} | tee -a "$LOG"

# Se registra el inicio de la auditoría en el log y en pantalla
echo "[+] Iniciando auditoria_fase2.sh" | tee -a "$LOG"
echo "--------------------------------------------------" | tee -a "$LOG"

# Se define la lista de scripts a ejecutar en el servidor remoto
for s in 01_auditar_inicial_bd.sh 02_configurar_firewall.sh 03_ajustar_permisos.sh; do
  # Se informa qué script se va a ejecutar
  echo -e "\n[+] Ejecutando script: $s" | tee -a "$LOG"
  echo "--------------------------------------------------" | tee -a "$LOG"

  # 1. Se copia el script al servidor remoto (en /tmp)
  scp "./scripts/fase2/$s" "$USER@$TARGET:/tmp/$s" > /dev/null

  # 2. Se ejecuta el script de forma remota con sudo usando -t y -S
  # -t: asigna pseudo-terminal para confiabilidad
  # -S: lee contraseña desde stdin
  # 3. Después de ejecutarlo, se elimina el script para limpiar el entorno
  echo "$SUDO_PASS" | ssh -t "$USER@$TARGET" "sudo -S bash /tmp/$s && rm /tmp/$s" | tee -a "$LOG"
done

# Limpia la variable de entorno con la contraseña por seguridad
unset SUDO_PASS

# Se registra el fin de la auditoría
echo -e "\n[+] Fin auditoria_fase2.sh" | tee -a "$LOG"
echo "==================================================" | tee -a "$LOG"
echo "Log completo guardado en: $LOG" | tee -a "$LOG"