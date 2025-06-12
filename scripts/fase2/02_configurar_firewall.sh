#!/bin/bash

# Activa el firewall y abre solo los servicios necesarios
systemctl enable --now firewalld
ZONA=$(firewall-cmd --get-default-zone)

firewall-cmd --permanent --zone="$ZONA" --add-service=ssh
firewall-cmd --permanent --zone="$ZONA" --add-port=3306/tcp
firewall-cmd --reload