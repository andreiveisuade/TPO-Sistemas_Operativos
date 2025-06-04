#!/bin/bash
# set -e
set -u

echo "INFO: Listando repositorios DNF habilitados..."
sudo dnf repolist enabled
echo "----------------------------------------"
echo ""

echo "INFO: Verificando archivos de configuración de repositorios en /etc/yum.repos.d/..."
echo "      (Se listarán archivos que NO parezcan estándar de RHEL/EPEL. Revisar manualmente)"
REPOS_ESTANDAR_PATTERN='(redhat\.repo|rhel\.repo|epel\.repo|.*rpmnew|.*rpmsave)'
archivos_repo_sospechosos=$(ls /etc/yum.repos.d/ | grep -vE "$REPOS_ESTANDAR_PATTERN")

if [ -n "$archivos_repo_sospechosos" ]; then
    echo "$archivos_repo_sospechosos"
else
    echo "INFO: No se encontraron archivos de repo con nombres sospechosos/personalizados."
fi
echo "--------------------------------------------------------------------------------"
echo ""

echo "INFO: Intentando listar paquetes instalados que NO provengan de repositorios comunes..."
echo "      (Esta es una heurística. Puede haber falsos positivos/negativos. Revisar manualmente.)"

# Mejoramos la legibilidad y el manejo de la salida de awk
paquetes_no_estandar=$(sudo dnf list installed | awk '
NF == 3 {
    repo=$3
    # Repositorios conocidos. Añadir más si es necesario para tu entorno.
    # El patrón @System se refiere a paquetes instalados fuera de dnf (ej. compilados) o de Kickstart
    if (repo !~ /^@(AppStream|BaseOS|epel|extras|crb|powertools|System)$/ && \
        repo !~ /^(rhel-|fedora-)/ && \
        repo !~ /redhat/ && repo !~ /fedora/ && \
        repo != "@@commandline" && repo != "anaconda" && repo != "installed") {
        print "Paquete: " $1 " (Versión: " $2 ", Desde Repo: " repo ")"
    }
}')

if [ -n "$paquetes_no_estandar" ]; then
    echo "$paquetes_no_estandar"
else
    echo "INFO: No se detectaron paquetes de repositorios claramente no estándar con este método."
fi
echo "------------------------------------------------------------------------------------------------"