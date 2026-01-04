#!/bin/bash

# --- CONFIGURACION ---
# Script de instalacion de Go.

# 1. EVITAR EJECUCION CON SUDO DIRECTO
if [ "$EUID" -eq 0 ]; then
    echo "ALERTA: No uses sudo para iniciar este script."
    echo "Ejecuta: ./install_go.sh <version>"
    echo "El script solicitara la contrasena mas adelante."
    exit 1
fi

# 2. Validar argumento
if [ -z "$1" ]; then
    echo "Error: Falta el numero de version. Ejemplo: 1.23.4"
    exit 1
fi

GO_VERSION=$1
OS="linux"
ARCH=""

# 3. Detectar arquitectura
machine_arch=$(uname -m)
case $machine_arch in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv6l) ARCH="armv6l" ;;
    *) echo "Error: Arquitectura $machine_arch no soportada."; exit 1 ;;
esac

# 4. Detectar Shell
USER_SHELL_NAME=$(basename "$SHELL")
if [ "$USER_SHELL_NAME" = "zsh" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ "$USER_SHELL_NAME" = "bash" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
else
    SHELL_PROFILE="$HOME/.profile"
fi

echo "--- Instalando Go $GO_VERSION para $ARCH ---"

FILE_NAME="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
URL="https://go.dev/dl/${FILE_NAME}"

# 5. Descargar (Forzando sobrescritura)
echo "Descargando..."
# El parametro -O asegura que se reemplace cualquier archivo corrupto previo
wget -q --show-progress -O "$FILE_NAME" "$URL"

if [ $? -ne 0 ]; then
    echo "Error en la descarga. Verifica tu conexion."
    rm "$FILE_NAME" 2>/dev/null
    exit 1
fi

# Validar que no sea una pagina de error (archivo muy pequeno)
FILE_SIZE=$(du -m "$FILE_NAME" | cut -f1)
if [ "$FILE_SIZE" -lt 10 ]; then
    echo "Error: El archivo descargado pesa menos de 10MB ($FILE_SIZE MB)."
    echo "Es probable que la version $GO_VERSION no exista."
    rm "$FILE_NAME"
    exit 1
fi

# 6. Instalacion (Se requieren permisos aqui)
echo "Instalando en /usr/local..."

# Invalida cache de sudo para asegurar que pida contrasena si es necesario
sudo -k 

if sudo true; then
    # Limpiar version anterior
    if [ -d "/usr/local/go" ]; then
        sudo rm -rf /usr/local/go
    fi

    echo "Descomprimiendo archivos..."
    sudo tar -C /usr/local -xzf "$FILE_NAME"
    
    # REPARAR PERMISOS (Crucial para evitar 'permission denied')
    echo "Ajustando permisos de archivos..."
    sudo chown -R root:root /usr/local/go
    sudo chmod -R 755 /usr/local/go
    
    rm "$FILE_NAME"
else
    echo "Error: No se obtuvieron permisos de administrador."
    exit 1
fi

# 7. Configuracion del Entorno
GO_BLOCK="export GOPATH=\$HOME/go
export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin"

if grep -q "/usr/local/go/bin" "$SHELL_PROFILE"; then
    echo "La configuracion del PATH ya existe en $SHELL_PROFILE."
else
    echo "" >> "$SHELL_PROFILE"
    echo "# Go Configuration" >> "$SHELL_PROFILE"
    echo "$GO_BLOCK" >> "$SHELL_PROFILE"
    echo "Variables de entorno agregadas a $SHELL_PROFILE."
fi

echo "------------------------------------------------"
echo "Instalacion finalizada."
echo "Versión instalada: $(/usr/local/go/bin/go version)"
echo ""
echo "Para aplicar los cambios ejecuta:"
echo "   source $SHELL_PROFILE"
echo "   go version"
echo "Para más detalles, consulta la documentación oficial: https://go.dev/doc/install"
echo "------------------------------------------------"