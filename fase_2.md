# Guía Paso a Paso - Ejecución Fase 2

## Prerequisitos
- Tener ambos servidores (`workstation` y `utility`) encendidos
- Estar conectado por SSH o consola en `workstation`
- Haber completado la Fase 1 exitosamente

---

## Paso 1: Verificar conectividad SSH
Desde `workstation`, verifica que puedas conectarte a `utility`:

```bash
ssh student@utility
```

**Resultado esperado:** Debería pedirte la contraseña y permitirte acceder. Escribe `exit` para salir.

---

## Paso 2: Reemplazar el archivo de la Fase 2
Reemplaza tu archivo `auditoria_fase2.sh` actual con la versión corregida que incluye `-t` y `-S`.

```bash
# Hacer backup del original (opcional)
cp auditoria_fase2.sh auditoria_fase2.sh.backup

# Ahora reemplaza el contenido con la versión corregida
```

---

## Paso 3: Dar permisos de ejecución
```bash
chmod +x auditoria_fase2.sh
```

---

## Paso 4: Ejecutar la Fase 2
```bash
./auditoria_fase2.sh student utility
```

---

## ¿Qué va a pasar?

### 4.1 Solicitud de contraseña
El script te va a pedir:
```
Ingrese la contraseña de sudo para student@utility: 
```

**Escribe la contraseña del usuario `student`** (normalmente es `student` también). No verás los caracteres mientras escribes (esto es normal por seguridad).

### 4.2 Ejecución de scripts
Verás algo como esto:

```
==================================================
=== AUDITORÍA FASE 2: Endurecimiento del sistema ===
Target: utility
Usuario: student
Fecha de ejecución: 2025-06-12 12:30:45 -03
==================================================

[+] Iniciando auditoria_fase2.sh
--------------------------------------------------

[+] Ejecutando script: 01_auditar_inicial_bd.sh
--------------------------------------------------
========== AUDITORÍA DE SERVICIOS Y CONEXIONES ==========
Hostname: utility
[... salida del script ...]

[+] Ejecutando script: 02_configurar_firewall.sh
--------------------------------------------------
========== CONFIGURACIÓN DE FIREWALL ==========
[... salida del script ...]

[+] Ejecutando script: 03_ajustar_permisos.sh
--------------------------------------------------
========== AJUSTE DE PERMISOS ==========
[... salida del script ...]

[+] Fin auditoria_fase2.sh
==================================================
Log completo guardado en: ./logs_auditoria/fase2_workstation_to_utility_20250612_123045.log
```

---

## Paso 5: Verificar que funcionó
Para comprobar que el firewall se configuró correctamente:

```bash
./auditoria_fase1.sh utility
```

O directamente:
```bash
nmap utility
```

**Resultado esperado:** Deberías ver menos puertos abiertos que en el escaneo inicial.

---

## Paso 6: Revisar el log generado
```bash
ls -la logs_auditoria/
cat logs_auditoria/fase2_workstation_to_utility_*.log
```

---

## Si algo sale mal:

### Error: "Permission denied"
- Verifica que el archivo tenga permisos de ejecución: `chmod +x auditoria_fase2.sh`

### Error: "Connection refused" o similar
- Verifica conectividad: `ping utility`
- Verifica SSH: `ssh student@utility`

### Error: "sudo: a terminal is required"
- Asegúrate de estar usando la versión corregida del script con `-t` y `-S`

### Error: "Wrong password" o similar
- La contraseña del usuario `student` normalmente es `student`
- Prueba conectarte manualmente: `ssh student@utility` para verificar la contraseña

---

## Archivos que se generan:
- **Log principal:** `./logs_auditoria/fase2_workstation_to_utility_YYYYMMDD_HHMMSS.log`
- **Carpeta de logs:** `./logs_auditoria/` (se crea automáticamente)