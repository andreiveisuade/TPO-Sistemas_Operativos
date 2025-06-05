# Guía de Ejecución Unidad 6 - Auditoría y Endurecimiento

### Escenario

* **workstation**: Servidor de aplicaciones. Ejecuta el escaneo remoto.
* **utility**: Servidor de base de datos. Es el objetivo del escaneo y endurecimiento.

---

### Paso 1: Iniciar los servidores necesarios

Desde el panel de Red Hat levantar y hacer **Open Console** de:

- `workstation`
- `utility`

---

### Paso 2: Acceder a la consola de `workstation`

1. Clic en **Open Console** de `workstation`.
2. Iniciar sesión como `student` (o el usuario asignado).

---

### Paso 2.1: Verificaciones previas

1. Instalar `nmap` con:

```bash
sudo dnf install nmap
```

2. Verificar que `nmap` esta instalado con:

```bash
nmap --version
```

3. Hacer un `ip route` para verificar la ruta de red

### Paso 3 Verificar conectividad con `utility`

```bash
ping 5 utility
```

Debe responder con paquetes recibidos.


### Paso 4 Dar permisos de ejecución

```bash
chmod +x auditoria_fase1.sh
chmod +x auditoria_fase2.sh
chmod +x scripts/01_escanear.sh
chmod +x scripts/02_configurar_firewall.sh
chmod +x scripts/03_ajustar_permisos.sh
```


### Paso 5 Ejecutar Fase 1 - Escaneo remoto

Desde `workstation`, ejecutar:

```bash
bash ./auditoria_fase1.sh utility
```

Esto realizará el escaneo remoto y generará un reporte en `workstation` en la carpeta `reportes`.

### Paso 6 Verificar acceso SSH a `utility`

```bash
ssh student@utility
```

Debe responder con la contraseña del usuario `student`.

### Paso 7 Ejecutar Fase 2 - Endurecimiento

Desde `workstation`, ejecutar:

```bash
bash ./auditoria_fase2.sh utility
```

Esto realizará el endurecimiento remoto y generará un reporte en `workstation` en la carpeta `reportes`.



xrandr --output $(xrandr | grep " connected" | awk '{ print $1 }') --mode 1920x1080 ; gsettings set org.gnome.desktop.interface text-scaling-factor 1.5