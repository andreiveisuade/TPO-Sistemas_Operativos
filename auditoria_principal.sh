#!/bin/bash

echo "== Iniciando auditoría de seguridad =="
for script in scripts/*.sh; do
  echo "== Ejecutando: $script =="
  bash "$script"
  echo ""
done
echo "== Auditoría finalizada =="