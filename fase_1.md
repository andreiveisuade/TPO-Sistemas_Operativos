
# Guía Paso a Paso - Ejecución Fase 1

## Prerequisitos
- Tener ambos servidores (`workstation` y `utility`) encendidos
- xrandr --output $(xrandr | grep " connected" | awk '{ print $1 }') --mode 1920x1080 ; gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
- git clone https://github.com/andreiveisuade/TPO-Sistemas_Operativos.git

---

## Paso 1: Iniciar sesión en workstation
1. Desde el panel de Red Hat, hacer clic en **Open Console** de `workstation`
2. Iniciar sesión como `student` (contraseña normalmente es `student`)

---

## Paso 2: Instalar herramientas necesarias
```bash
sudo dnf install nmap -y
```

**Verificar instalación:**
```bash
nmap --version
```

**Resultado esperado:** Debería mostrar la versión de nmap instalada.

---

## Paso 3: Verificar conectividad de red
### 3.1 Verificar ruta de red
```bash
ip route
```

### 3.2 Hacer ping a utility
```bash
ping -c 5 utility
```

**Resultado esperado:** Debería recibir 5 respuestas exitosas.

---

## Paso 4: Obtener la IP de utility (opcional)
Si quieres saber la IP exacta:

```bash
# Escanear la red para encontrar dispositivos
nmap -sn 172.25.250.0/24

# Obtener específicamente la IP de utility
nmap -sn 172.25.250.0/24 | grep "utility" | awk -F '[()]' '{print $2}'
```

---

## Paso 5: Navegar al directorio del proyecto
```bash
cd TPO-Sistemas_Operativos
# o donde hayas clonado/copiado los archivos
```

**Verificar que estás en el directorio correcto:**
```bash
ls -la
```

**Deberías ver:**
- `auditoria_fase1.sh`
- `auditoria_fase2.sh`
- Carpeta `scripts/`
- `consigna.md`
- `guia_de_ejecucion.md`

---

## Paso 6: Dar permisos de ejecución
```bash
chmod +x auditoria_fase1.sh
chmod +x scripts/fase1/01_escanear.sh
```

**O usar el script automático:**
```bash
chmod +x dar_permisos.sh
./dar_permisos.sh
```

---

## Paso 7: Ejecutar la Fase 1

### Opción A: Usando el nombre del host
```bash
./auditoria_fase1.sh utility
```

### Opción B: Usando la IP (si la obtuviste antes)
```bash
./auditoria_fase1.sh 172.25.250.X
```

### Opción C: Combinando el comando para obtener la IP automáticamente
```bash
./auditoria_fase1.sh $(nmap -sn 172.25.250.0/24 | grep "utility" | awk -F '[()]' '{print $2}')
```

---

## ¿Qué va a pasar?

### 7.1 Inicio del escaneo
Verás algo como:
```
[+] Iniciando auditoria_fase1.sh
[+] Escaneo rápido de puertos (-F)
Starting Nmap X.XX ( https://nmap.org ) at 2025-06-12 12:00 -03
Nmap scan report for utility (172.25.250.X)
Host is up (0.00015s latency).
Not shown: 96 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
443/tcp  open  https
3306/tcp open  mysql
```

### 7.2 Detección de versiones
```
[+] Detección de versiones de servicios (-sV)
Starting Nmap X.XX ( https://nmap.org ) at 2025-06-12 12:00 -03
Nmap scan report for utility (172.25.250.X)
Host is up (0.00020s latency).
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH X.X
80/tcp   open  http    Apache httpd X.X.X
443/tcp  open  https   Apache httpd X.X.X
3306/tcp open  mysql   MySQL X.X.X
```

### 7.3 Finalización
```
[+] Fin auditoria_fase1.sh
```

---

## Paso 8: Verificar el log generado
```bash
# Listar logs generados
ls -la logs_auditoria/

# Ver el contenido del log más reciente
ls -t logs_auditoria/auditoria_Fase1_* | head -1 | xargs cat
```

**O directamente:**
```bash
cat logs_auditoria/auditoria_Fase1_workstation_to_utility_*.txt
```

---

## ¿Qué información importante obtuvimos?

Del escaneo deberías identificar:

### Puertos abiertos típicos:
- **Puerto 22 (SSH):** ✅ Necesario para administración remota
- **Puerto 80 (HTTP):** ❌ Innecesario en servidor de BD
- **Puerto 443 (HTTPS):** ❌ Innecesario en servidor de BD  
- **Puerto 3306 (MySQL):** ✅ Necesario para base de datos

### Servicios corriendo:
- OpenSSH (necesario)
- Apache (innecesario para un servidor de BD)
- MySQL (necesario)

---

## Problemas comunes y soluciones:

### Error: "nmap: command not found"
```bash
sudo dnf install nmap -y
```

### Error: "Permission denied"
```bash
chmod +x auditoria_fase1.sh
chmod +x scripts/fase1/01_escanear.sh
```

### Error: "No route to host" o timeouts
- Verificar que `utility` está encendido
- Hacer `ping utility` para verificar conectividad

### Error: "bash: ./auditoria_fase1.sh: No such file or directory"
- Verificar que estás en el directorio correcto: `pwd`
- Listar archivos: `ls -la`

---

## Paso 9: Interpretar resultados
Con la información del escaneo ya puedes:

1. **Identificar servicios innecesarios** (HTTP/HTTPS en servidor de BD)
2. **Planificar el endurecimiento** para la Fase 2
3. **Documentar el estado inicial** del servidor

¡Ahora ya estás listo para ejecutar la Fase 2!