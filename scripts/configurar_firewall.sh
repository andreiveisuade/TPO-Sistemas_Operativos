#!/bin/bash
echo "[Configuración de Firewall]"
sudo firewall-cmd --permanent --remove-service=ftp
sudo firewall-cmd --permanent --remove-service=telnet
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
sudo firewall-cmd --list-all