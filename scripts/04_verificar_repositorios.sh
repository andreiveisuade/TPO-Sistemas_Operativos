#!/bin/bash
set -u

echo "Repositorios DNF habilitados:"
sudo dnf repolist enabled --quiet # Menos verboso
echo "---"
echo "Archivos .repo en /etc/yum.repos.d/ (excl. rhel, redhat, epel):"
ls /etc/yum.repos.d/ | grep -vE '(redhat\.repo|rhel\.repo|epel\.repo|.*rpmnew|.*rpmsave)' || echo "Ninguno sospechoso por nombre."
echo "---"
echo "Paquetes instalados potencialmente no estándar (revisar origen):"
sudo dnf list installed | awk 'NF==3 && $3 !~ /^@(AppStream|BaseOS|epel|System)$/ && $3 !~ /^(rhel-|fedora-|redhat|fedora)/ && $3 !~ /@@commandline|anaconda|installed/ {print $1 " (Repo: " $3 ")"}' || echo "No se encontraron paquetes con este filtro."