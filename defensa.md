Diapositiva 1: Título

Título: Fortalecimiento del Servidor de Producción: Auditoría y Endurecimiento.
Tu Nombre / Materia / etc.
Discurso:
"Buenos días. En esta presentación defenderé el trabajo práctico realizado, cuyo objetivo fue aplicar medidas de seguridad y endurecimiento sobre un servidor Red Hat, basándonos en los conceptos teóricos de Sistemas Operativos.

El problema planteado es un escenario muy común en la industria: un nuevo servidor de base de datos que debe ser asegurado antes de su exposición a un entorno público. Nuestra estrategia general se basa en el principio de Defensa en Profundidad, que, como vimos en la Unidad VI, consiste en establecer múltiples capas de seguridad.

El objetivo es proteger la Confidencialidad, la Integridad y la Disponibilidad del sistema, abordando las amenazas que se describen en la teoría, como los intrusos o la exposición no autorizada de servicios."

Diapositiva 2: Fase 1 - Descubrimiento y Análisis del Entorno

Título: Fase 1: Identificación de la Superficie de Ataque.
(Muestra el log de la Fase 1 aquí, donde se ven los puertos 80 y 443 abiertos).
Discurso:
"El primer paso de cualquier auditoría de seguridad es el reconocimiento. Tal como se describe en la Unidad VI bajo 'Aspectos del entorno de seguridad', antes de poder proteger un sistema, debemos entender su estado actual y sus posibles debilidades.

Para ello, ejecutamos el script auditoria_fase1.sh. Este script, desde el 'servidor de aplicaciones', realiza un escaneo de puertos sobre el 'servidor de base de datos' utilizando la herramienta nmap.

Teóricamente, lo que estamos haciendo es identificar la superficie de ataque del sistema. Es decir, todos los puntos por los cuales un potencial intruso podría intentar interactuar con el servidor.

Como pueden ver en el log, el resultado de la Fase 1 fue revelador. Además de los puertos esperados como el 22 para SSH y el 3306 para MySQL, encontramos los puertos 80 (http) y 443 (https) abiertos. Esto representa una vulnerabilidad crítica, ya que un servidor de base de datos dedicado no debería estar exponiendo un servicio web. Este hallazgo justifica y guía todas las acciones que tomaremos en la Fase 2."

Diapositiva 3: Fase 2 - Endurecimiento del Sistema (Firewall)

Título: Fase 2.1: Mecanismo de Protección - Implementación de Firewall.
(Muestra el código de tu script scripts/fase2/02_configurar_firewall.sh).
Discurso:
"Una vez identificada la superficie de ataque, procedimos con la Fase 2: el endurecimiento. La primera medida corresponde directamente al concepto de Defensas de la Unidad VI, específicamente la implementación de un Firewall.

Un firewall, como se explica en la teoría, actúa como un filtro de paquetes, controlando el tráfico entrante y saliente. Nuestro script 02_configurar_firewall.sh automatiza la configuración de firewalld en el servidor remoto.

El enfoque aquí se basa en el principio de menor autoridad (POLA), un concepto clave de los mecanismos de protección. No solo nos aseguramos de que los servicios necesarios estén permitidos, sino que, de forma proactiva, eliminamos los servicios innecesarios.

Como ven en el código, el script:

Elimina las reglas para los servicios http y https, que habíamos identificado como un riesgo.
Asegura que el servicio ssh esté permitido, garantizando la disponibilidad para la administración.
Permite explícitamente el puerto 3306/tcp, que es el servicio principal de la base de datos.
Con esto, estamos limitando drásticamente la superficie de ataque, dejando solo los puntos de entrada estrictamente necesarios."

Diapositiva 4: Fase 2 - Endurecimiento del Sistema (Permisos)

Título: Fase 2.2: Mecanismo de Protección - Integridad del Sistema de Archivos.
(Muestra el código de tu script scripts/fase2/03_ajustar_permisos.sh).
Discurso:
"La segunda capa de nuestra defensa en profundidad se enfoca en la integridad del sistema de archivos. Para esto, aplicamos otro mecanismo de protección fundamental de la Unidad VI: el control de acceso a objetos.

Nuestro script 03_ajustar_permisos.sh revisa y ajusta los permisos de archivos y directorios críticos. Aquí conectamos la teoría de la Unidad IV (Sistemas de Archivos) con la de seguridad. Como vimos en la Unidad IV, cada archivo posee atributos de protección (lectura, escritura, ejecución) para el propietario, el grupo y otros.

Nuestro script asegura que estos atributos sigan una configuración segura. Por ejemplo:

chmod 600 /etc/shadow: Este comando asegura que el archivo de contraseñas solo pueda ser leído y escrito por su propietario (root), protegiendo la confidencialidad de las credenciales de usuario.
chmod 700 /var/lib/mysql: Protege el directorio de datos de la base de datos, asegurando que solo el servicio de MySQL (que corre con privilegios específicos) pueda acceder a él.
Esta acción es una implementación práctica de la gestión de dominios de protección, donde garantizamos que solo los procesos autorizados puedan acceder a los objetos críticos del sistema."

Diapositiva 5: Verificación y Conclusión

Título: Verificación de Resultados y Conclusión.
(Muestra lado a lado el log de la Fase 1 "antes" y el log de la Fase 1 "después" del endurecimiento. En el "después", los puertos 80 y 443 deben aparecer cerrados. También muestra el log final de la Fase 2, donde se ve la configuración final del firewall).
Discurso:
"Para validar la efectividad de nuestras acciones, volvimos a ejecutar la Fase 1 después del endurecimiento. Como pueden observar, el nuevo escaneo muestra que los puertos 80 y 443 ahora están cerrados. Esto confirma que hemos reducido exitosamente la superficie de ataque.

El log final de la Fase 2 es la evidencia concluyente de nuestro trabajo. Muestra la auditoría inicial, los pasos de configuración del firewall y el ajuste de permisos, y la configuración final del firewall que confirma que solo ssh y mysql están permitidos.

En conclusión, este trabajo práctico nos permitió aplicar de manera tangible los conceptos teóricos de seguridad. Implementamos una estrategia de defensa en profundidad para minimizar las amenazas. Utilizamos firewalls para controlar el acceso a la red y ajustamos los atributos de protección de archivos para garantizar la integridad y confidencialidad del sistema. El proceso fue completamente automatizado mediante scripts, demostrando cómo la teoría de Sistemas Operativos se traduce en prácticas de administración de sistemas seguras y eficientes.

Muchas gracias."
