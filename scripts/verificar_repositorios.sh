#!/bin/bash
echo "[Repositorios y paquetes]"
dnf repolist
echo "[Paquetes no oficiales sospechosos:]"
dnf list installed | grep -vE '(@base|@appstream|@epel|@rhel|@fedora)'