#!/bin/bash
echo "[Análisis de accesos SSH]"
sudo grep -E "Failed|Accepted" /var/log/secure | tail -n 20