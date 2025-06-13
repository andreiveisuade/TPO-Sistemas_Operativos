#!/bin/bash

# Ajusta permisos de archivos y directorios críticos

echo "========== AJUSTE DE PERMISOS =========="
echo "Hostname: $(hostname)"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"

# Lista de archivos o directorios con permisos deseados (ruta:permiso)
ITEMS=(
  "/etc/shadow:600"
  "/etc/gshadow:600"
  "/etc/passwd:644"
  "/etc/group:644"
  "/root:700"
  "/var/lib/mysql:700"
)

# Si existe /etc/my.cnf lo agregamos a la lista
[[ -f /etc/my.cnf ]] && ITEMS+=("/etc/my.cnf:600")

# Recorremos cada ítem
for item in "${ITEMS[@]}"; do
  path="${item%%:*}"
  desired="${item##*:}"

  if [[ -e "$path" ]]; then
    actual=$(stat -c "%a" "$path")
    if [[ "$actual" != "$desired" ]]; then
      chmod "$desired" "$path"
      echo "✔ $path: $actual → $desired (modificado)"
    else
      echo "✓ $path: ya tenía permisos $actual"
    fi
  else
    echo "✘ $path: no existe, no se pudo aplicar permisos"
  fi
done