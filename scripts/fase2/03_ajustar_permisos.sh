#!/bin/bash
set -eu

ARCHIVOS=(
  "/etc/shadow:600"
  "/etc/gshadow:600"
  "/etc/passwd:644"
  "/etc/group:644"
  "/root:700"
  "/var/lib/mysql:700"
  "/etc/my.cnf:600"
)

for item in "${ARCHIVOS[@]}"; do
  path="${item%%:*}"
  perm="${item##*:}"
  [[ -e "$path" ]] || { echo "No existe $path"; continue; }

  actual=$(stat -c "%a" "$path")
  if [ "$actual" != "$perm" ]; then
    chmod "$perm" "$path" && echo "✔ $path → $perm"
  else
    echo "✓ $path ya tiene permisos correctos"
  fi
done