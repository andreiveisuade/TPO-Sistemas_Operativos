# Unidad 6 - Trabajo Práctico

## “Fortalecimiento del Servidor de Producción: Auditoría y Endurecimiento”

### Planteamiento del Problema

Una pequeña empresa ha desplegado recientemente dos servidores basados en Red Hat: uno para aplicaciones web y otro para base de datos. Ante la inminente conexión con el entorno público, el responsable de sistemas recibe la orden de realizar una auditoría de seguridad básica y aplicar medidas de endurecimiento del sistema operativo.

### Se requiere:

1. Escanear el servidor de base de datos desde el servidor de aplicaciones para identificar puertos abiertos.
2. Limitar los servicios activos y aplicar reglas de firewall estrictas.
3. Revisar y ajustar permisos de archivos y directorios sensibles.

El objetivo es registrar todas las acciones en un archivo de log y automatizar parte del proceso con bash.

### Objetivos de Seguridad Cubiertos

- Mínima superficie de ataque (puertos/servicios).
- Integridad del sistema de archivos y configuraciones.