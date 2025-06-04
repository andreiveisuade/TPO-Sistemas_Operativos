#!/bin/bash
# set -e
set -u

echo "INFO: Auditoría de Cuentas de Usuario."
echo "----------------------------------------------"
echo "Listado de todos los nombres de usuario locales:"
cut -d: -f1 /etc/passwd
echo "---"

echo "Usuarios con UID 0 (privilegios de root):"
awk -F: '($3 == 0) { print "  UID 0: " $1 }' /etc/passwd
echo "---"

echo "Usuarios 'humanos' (UID >= 1000, excl. nfsnobody 65534):"
awk -F: '($3 >= 1000 && $3 != 65534) { print "  Usuario: " $1 " (UID: " $3 ", Shell: " $7 ")" }' /etc/passwd
echo "---"

echo "Verificando /etc/shadow para contraseñas vacías o cuentas bloqueadas:"
# La salida de awk irá al log, aquí solo un resumen.
num_alertas_shadow=$(sudo awk -F: '
{
    if ($2 == "") {
        print "ALERTA_SHADOW: Contraseña literalmente VACÍA para el usuario: " $1; count_vacia++
    } else if (substr($2,1,1) == "!" || substr($2,1,1) == "*") {
        if (substr($2,1,2) == "!!" ) {
             print "INFO_SHADOW: Contraseña BLOQUEADA (expirada/nunca set) para: " $1; count_bloqueada_exp++
        } else {
             print "INFO_SHADOW: Cuenta probablemente BLOQUEADA (sin login pass directo) para: " $1; count_bloqueada++
        }
    }
}
END {
    print "RESUMEN_SHADOW: Vacías="count_vacia+0 "; Bloq/Exp="count_bloqueada_exp+0 "; Bloq/SinPass="count_bloqueada+0
}' /etc/shadow) # La salida real detallada va al log principal

echo "$num_alertas_shadow" # Esto mostrará el resumen en pantalla
echo "----------------------------------------------------------------------------"
echo "INFO: Detalles de alertas de /etc/shadow están en el archivo de log principal."