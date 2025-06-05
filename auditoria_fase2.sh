cat << 'EOF' > auditoria_fase2.sh
#!/bin/bash
set -u

if [ $# -ne 2 ]; then
    echo "Uso: $0 <usuario> <ip_servidor>"
    exit 1
fi

USUARIO="$1"
IP="$2"

echo "== Conectando a $IP como $USUARIO para ejecutar endurecimiento... =="

# Ejecutar scripts remotos por SSH
echo "-- Ejecutando configuración de firewall --"
ssh "$USUARIO@$IP" 'bash -s' < scripts/fase2/02_configurar_firewall.sh

echo "-- Ajustando permisos críticos --"
ssh "$USUARIO@$IP" 'bash -s' < scripts/fase2/03_ajustar_permisos.sh

echo "✅ Fase 2 finalizada."
EOF

chmod +x auditoria_fase2.sh