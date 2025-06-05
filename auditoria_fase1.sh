#!/bin/bash
# Establece el intérprete de comandos a usar (bash)

# Configuración de opciones del shell:
# -u: Genera un error al usar variables no definidas
set -u

# ===== FUNCIONES AUXILIARES =====
mostrar_ayuda() {
    echo "Uso: $0 <ip_servidor>"
    echo "Ejemplo: $0 192.168.1.100"
    echo "\nArgumentos:"
    echo "  <ip_servidor>  Dirección IP del servidor a auditar (requerido)"
    exit 1
}

# Validar parámetros
if [ $# -ne 1 ]; then
    echo "Error: Se requiere la dirección IP del servidor como parámetro"
    mostrar_ayuda
fi

# Validar formato de IP (solo verifica que tenga el formato básico)
if [[ ! $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Error: El formato de la IP no es válido"
    mostrar_ayuda
fi

# Asignar IP del parámetro
IP_SERVIDOR_BD="$1"

# ===== CONFIGURACIÓN INICIAL =====
# Directorio donde se guardarán los logs
LOG_DIR="./logs_auditoria"
# Crear el directorio de logs si no existe
# -p: Crea directorios padres si no existen
mkdir -p "$LOG_DIR"

# Generar nombre de archivo de log con marca de tiempo
# Formato: auditoria_<nombre_host>_<AAAAMMDD_HHMMSS>.txt
FECHA=$(date +"%Y%m%d_%H%M%S")
LOG="${LOG_DIR}/auditoria_$(hostname)_${FECHA}.txt"

# Iniciar el archivo de log con información de la auditoría
echo "INICIO DE AUDITORÍA: $(date)" > "$LOG"
echo "Servidor objetivo: $IP_SERVIDOR_BD" >> "$LOG"
echo "" >> "$LOG"

# ===== EJECUCIÓN DE SCRIPTS DE AUDITORÍA =====
# Verificar si existe el directorio de scripts
if [ ! -d "scripts" ]; then
    echo "Error: No se encontró el directorio 'scripts'" | tee -a "$LOG"
    exit 1
fi

# Contador de scripts ejecutados
CONTADOR=0

# Itera sobre todos los scripts en el directorio scripts/ que sigan el patrón ??_*.sh
# Los scripts se ejecutan en orden numérico (01_*.sh, 02_*.sh, etc.)
for script in scripts/fase1/*.sh; do
    # Verificar si el archivo existe (en caso de que no haya scripts)
    [ -f "$script" ] || continue
    
    # Incrementar contador
    ((CONTADOR++))
    
    # Mostrar en consola y guardar en log el script que se está ejecutando
    echo "== Ejecutando $script ==" | tee -a "$LOG"
    
    # Verificar si es el script de escaneo (que necesita la IP como parámetro)
    if [[ "$(basename "$script")" == "01_escanear.sh" ]]; then
        # Ejecutar script de escaneo con la IP como parámetro
        # >> "$LOG" 2>&1: Redirige tanto la salida estándar como la de error al archivo de log
        bash "$script" "$IP_SERVIDOR_BD" >> "$LOG" 2>&1
    else
        # Ejecutar otros scripts sin parámetros adicionales
        bash "$script" >> "$LOG" 2>&1
    fi

    # Verificar el código de salida del script ejecutado
    # $? contiene el código de salida del último comando ejecutado
    # -ne 0: Verifica si el comando falló (código distinto de cero)
    if [ $? -ne 0 ]; then
        # Mostrar error si el script falló
        echo "ERROR al ejecutar $script" | tee -a "$LOG"
    else
        # Confirmar que el script se ejecutó correctamente
        echo "$script completado" | tee -a "$LOG"
    fi
    
    # Agregar línea en blanco para mejor legibilidad en el log
    echo "" >> "$LOG"
done

# Verificar si se ejecutó al menos un script
if [ $CONTADOR -eq 0 ]; then
    echo "Advertencia: No se encontraron scripts para ejecutar en el directorio 'scripts/'" | tee -a "$LOG"
fi

# ===== FINALIZACIÓN =====
# Registrar hora de finalización y ubicación del log
echo "FIN DE AUDITORÍA: $(date)" >> "$LOG"
echo "Log guardado en: $LOG"
# Mostrar ubicación del log en la consola
echo "Auditoría completada. Ver resultados en: $LOG"

exit 0