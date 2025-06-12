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

### Escaner la red con nmap

```bash
nmap -sn 172.25.250.0/24
nmap -sn 172.25.250.0/24 | grep "utility" | awk -F '[()]' '{print $2}'
```

El argumento -sn significa hacer un "ping" a la red, es decir que no hará escaneo de puertos, solo hará un escaneo de red para ver si hay dispositivos conectados.

La notación 172.25.250.0/24 define una red con máscara de 24 bits (255.255.255.0), lo cual significa que abarca las IPs desde 172.25.250.0 hasta 172.25.250.255.
Sin embargo, las direcciones .0 (red) y .255 (broadcast) no pueden asignarse a dispositivos. Por lo tanto, los hosts válidos están entre 172.25.250.1 y 172.25.250.254.


El resultado de esto se guarda en el log

## Fase 2

### Paso 5 - Comprobar la conexion SSH con `utility`

```bash
ssh student@utility
```

Debe responder con la contraseña del usuario `student`.

### Paso 6 - Ejecutar Fase 2 - Endurecimiento

Desde `workstation`, ejecutar:

```bash
./auditoria_fase2.sh student utility
```

Esto realizará el endurecimiento remoto y generará un reporte en `workstation` en la carpeta `reportes`.

### Paso 7 - Comprobar que los puertos se hayan cerrado

```bash
nmap utility
```

Debe responder con puertos cerrados.

o si no con:

```bash
./auditoria_fase1.sh utility
```





