# Unidad 6

## “Fortalecimiento del Servidor de Producción: Auditoría, Endurecimiento y Control de Integridad”

### Planteamiento del Problema

La empresa “TechLogix” ha desplegado recientemente dos servidores basados en Red Hat: uno para aplicaciones web y otro para base de datos. Ante la inminente conexión con el entorno público, el responsable de sistemas recibe la orden de realizar una auditoría de seguridad básica y aplicar medidas de endurecimiento del sistema operativo, siguiendo las buenas prácticas de seguridad.

## Se requiere:
1. Escanear el servidor de base de datos desde el servidor de aplicaciones para identificar puertos abiertos.
2. Limitar los servicios activos y aplicar reglas de firewall estrictas.
3. Revisar y ajustar permisos de archivos y directorios sensibles.
4. Detectar paquetes instalados desde fuentes no oficiales o sospechosas.
5. Asegurarse de que solo usuarios autorizados tengan cuentas activas, y que no existan contraseñas vacías.
6. Registrar todas las acciones en un archivo de log.
7. Automatizar parte del proceso con bash.



## Objetivos de Seguridad Cubiertos
•	Mínima superficie de ataque (puertos/servicios).
•	Integridad del sistema de archivos y configuraciones.
•	Control de usuarios y accesos.
•	Buenas prácticas de auditoría y documentación.
•	Uso exclusivo de comandos de terminal y bash scripting.