# Guía de Ejecución Unidad 6 - Auditoría y Endurecimiento

## Escenario

* **servera**: Servidor de aplicaciones. Ejecuta el escaneo remoto.
* **serverb**: Servidor de base de datos. Es el objetivo del escaneo y endurecimiento.

---

### Paso 1: Iniciar los servidores necesarios

Desde el panel de Red Hat levantar y **Open Console**:
  * `servera`
  * `serverb`

---

### Paso 2: Acceder a la consola de `servera`

1. Clic en **Open Console** de `servera`.
2. Iniciar sesión como `student` (o el usuario asignado).

---

### Paso 3: Verificar conectividad con `serverb`

Desde `servera`, ejecutar:

```bash
ping -c 3 serverb
```

Debe responder con paquetes recibidos.

---

### Paso 4: Ejecutar Fase 1 - Escaneo remoto

En `servera`, ejecutar:

```bash
bash auditoria_fase1.sh serverb
```

* Corre el escaneo remoto sobre `serverb`
* Genera un log en `logs_auditoria/`

---

### Paso 5: Verificar acceso SSH a `serverb`

En `servera`, ejecutar:

```bash
ssh student@serverb
```

* Aceptar la clave si lo solicita (`yes`)
* Ingresar la contraseña si es necesario

---

### Paso 6: Ejecutar Fase 2 - Endurecimiento remoto

Desde `servera`, ejecutar:

```bash
bash auditoria_fase2.sh student serverb
```

Esto:

* Se conecta a `serverb` por SSH
* Ejecuta `02_configurar_firewall.sh`
* Ejecuta `03_ajustar_permisos.sh`

---

### Resultado Esperado

* Log completo de escaneo en `servera/logs_auditoria/`
* Firewall y permisos endurecidos en `serverb`

---

### Notas finales

* Si `ping` o `ssh` fallan, reiniciá las VMs y verificá que ambas estén encendidas.
* También podés ejecutar `02_*.sh` y `03_*.sh` directamente en `serverb` desde su consola si preferís.
