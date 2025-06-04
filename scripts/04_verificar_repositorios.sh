#!/bin/bash
echo "Listando repositorios DNF habilitados..."
echo "----------------------------------------"
sudo dnf repolist enabled
echo "----------------------------------------"
echo ""

echo "Verificando archivos de configuración de repositorios en /etc/yum.repos.d/..."
echo "Se listarán archivos que NO contengan 'redhat.repo', 'rhel.repo' o 'epel.repo' (ajustar si es necesario)"
echo "--------------------------------------------------------------------------------"
ls /etc/yum.repos.d/ | grep -vE '(redhat\.repo|rhel\.repo|epel\.repo|.*rpmnew|.*rpmsave)' || echo "No se encontraron archivos de repo sospechosos/personalizados."
echo "--------------------------------------------------------------------------------"
echo ""

echo "Intentando listar paquetes instalados que no provengan de repositorios comunes de RHEL/EPEL..."
echo "(Esta lista puede incluir paquetes legítimos de terceros o compilados localmente. Revisar manualmente.)"
echo "------------------------------------------------------------------------------------------------"
# Este comando es una heurística y puede necesitar ajustes o producir falsos positivos/negativos.
# Intenta encontrar paquetes cuya información de repositorio no coincida con patrones comunes.
# La efectividad de esto es limitada sin herramientas más avanzadas de análisis de origen de paquetes.
sudo dnf list installed | awk '
NF == 3 { # Asegurar que la línea tiene 3 campos (paquete, versión, repositorio)
    repo=$3
    # Excluir repositorios conocidos y confiables
    if (repo !~ /^@(AppStream|BaseOS|epel|rhel-|fedora|System)$/ && \
        repo !~ /^(AppStream|BaseOS|epel|extras|powertools|crb|rhel-)/ && \
        repo !~ /redhat/ && repo !~ /fedora/ && \
        repo != "@@commandline" && repo != "anaconda" && repo != "installed") {
        print "Paquete potencialmente no estándar: " $1 " (Repo: " repo ")"
    }
}' || echo "No se pudieron listar paquetes o no se encontraron sospechosos con este método."
echo "------------------------------------------------------------------------------------------------"
echo "NOTA: Para una verificación más profunda, considera usar 'rpm -qi paquete | grep Vendor' para cada paquete sospechoso."