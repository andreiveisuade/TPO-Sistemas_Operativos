#!/bin/bash
echo "Listando todos los nombres de usuario locales..."
echo "----------------------------------------------"
cut -d: -f1 /etc/passwd
echo "----------------------------------------------"
echo ""

echo "Usuarios con UID 0 (privilegios de root)..."
echo "-------------------------------------------"
awk -F: '($3 == 0) { print "  UID 0: " $1 }' /etc/passwd
echo "-------------------------------------------"
echo ""

echo "Usuarios 'humanos' (UID >= 1000, excluyendo nfsnobody)..."
echo "-------------------------------------------------------"
awk -F: '($3 >= 1000 && $3 != 65534) { print "  Usuario Humano: " $1 " (UID: " $3 ", Shell: " $7 ")" }' /etc/passwd
echo "-------------------------------------------------------"
echo ""

echo "Verificando cuentas con contraseñas vacías o bloqueadas en /etc/shadow..."
echo "(Un campo de contraseña vacío es una grave vulnerabilidad)"
echo "(Campos con '!' o '*' usualmente indican cuentas bloqueadas o sin contraseña de login directa)"
echo "----------------------------------------------------------------------------"
# La opción -r es importante para que sudo no falle si no puede leer el archivo (aunque debería poder)
sudo awk -F: '
{
    if ($2 == "") {
        print "  ALERTA: Contraseña literalmente VACÍA para el usuario: " $1
    } else if (substr($2,1,1) == "!" || substr($2,1,1) == "*") {
        if (substr($2,1,2) == "!!" ) {
             print "  INFO: Contraseña BLOQUEADA (expirada o nunca establecida) para el usuario: " $1
        } else {
             print "  INFO: Cuenta probablemente BLOQUEADA (sin login directo por contraseña) para el usuario: " $1
        }
    }
}' /etc/shadow
echo "----------------------------------------------------------------------------"
echo "Revisar manualmente cualquier alerta. Las cuentas bloqueadas son normales para servicios."