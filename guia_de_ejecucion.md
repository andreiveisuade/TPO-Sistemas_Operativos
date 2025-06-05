# Guía de Ejecución Unidad 6 - Auditoría y Endurecimiento

### Escenario

* **servera**: Servidor de aplicaciones. Ejecuta el escaneo remoto.
* **serverb**: Servidor de base de datos. Es el objetivo del escaneo y endurecimiento.

---

### Paso 1: Iniciar los servidores necesarios

Desde el panel de Red Hat levantar y **Open Console**:
  * `workstation`
  * `utility`

---

### Paso 2: Acceder a la consola de `workstation`

1. Clic en **Open Console** de `workstation`.
2. Iniciar sesión como `student` (o el usuario asignado).

---

### Paso 2.1: Verificacion

1. Instalar nmap con `sudo dnf install nmap`
2. Verificar que nmap esta instalado con `nmap --version`
3. Hacer un ip route para verificar la ruta de red 


### Paso 3: Verificar conectividad con `utility`

Desde `workstation`, ejecutar:

```bash
ping 5 utility
```

Debe responder con paquetes recibidos.

---

### Paso 4.0: Dar permiso de Ejecución

Desde `workstation`, ejecutar:

```bash
chmod +x auditoria_fase1.sh
chmod +x auditoria_fase2.sh
chmod +x scripts/01_escanear.sh
chmod +x scripts/02_configurar_firewall.sh
chmod +x scripts/03_ajustar_permisos.sh
```

### Paso 4: Ejecutar Fase 1 - Escaneo remoto

En `workstation`, ejecutar:

```bash
bash auditoria_fase1.sh utility
```

* Corre el escaneo remoto sobre `utility`
* Genera un log en `logs_auditoria/`

---

### Paso 5: Verificar acceso SSH a `utility`

En `workstation`, ejecutar:

```bash
ssh student@utility
```

* Aceptar la clave si lo solicita (`yes`)
* Ingresar la contraseña si es necesario

---

### Paso 6: Ejecutar Fase 2 - Endurecimiento remoto

Desde `workstation`, ejecutar:

```bash
bash auditoria_fase2.sh student utility
```

Esto:

* Se conecta a `utility` por SSH
* Ejecuta `02_configurar_firewall.sh`
* Ejecuta `03_ajustar_permisos.sh`

---

### Resultado Esperado

* Log completo de escaneo en `workstation/logs_auditoria/`
* Firewall y permisos endurecidos en `utility`

---

### Notas finales

* Si `ping` o `ssh` fallan, reiniciá las VMs y verificá que ambas estén encendidas.
* También podés ejecutar `02_*.sh` y `03_*.sh` directamente en `utility` desde su consola si preferís.
