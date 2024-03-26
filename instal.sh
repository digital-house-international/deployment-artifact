#!/bin/bash

# Fonction pour afficher un message d'erreur et quitter le script
exit_with_error() {
    echo "Erreur: $1"
    exit 1
}

# Vérifier le nombre d'arguments
if [ "$#" -ne 1 ]; then
    exit_with_error "Utilisation: $0 <version_php>"
fi

# Version de PHP à installer et chemin vers le fichier tar.gz
version_php="$1"
script_dir=$(dirname "$0")
tar_file="$script_dir/php-$version_php.tar.gz"
extracted_dir="/tmp/php/php-$version_php"
install_dir="/tmp/makeinstall"

# Vérifier si le fichier tar.gz existe
if [ ! -f "$tar_file" ]; then
    exit_with_error "Le fichier $tar_file n'existe pas dans le répertoire du script"
fi

# Extraction du fichier tar.gz
echo "Extraction du fichier $tar_file..."
mkdir -p /tmp/php || exit_with_error "Impossible de créer le répertoire temporaire"
tar -zxf "$tar_file" -C /tmp/php || exit_with_error "Impossible d'extraire le fichier $tar_file"

# Installation des dépendances
echo "Installation des dépendances..."
if command -v apt &>/dev/null; then
    sudo apt install -y pkg-config build-essential autoconf bison re2c libxml2-dev libsqlite3-dev || exit_with_error "Impossible d'installer les dépendances"
elif command -v dnf &>/dev/null; then
    sudo dnf install -y re2c bison autoconf make libtool ccache libxml2-devel sqlite-devel || exit_with_error "Impossible d'installer les dépendances"
elif command -v yum &>/dev/null; then
    sudo yum install -y re2c bison autoconf make libtool ccache libxml2-devel sqlite-devel || exit_with_error "Impossible d'installer les dépendances"
else
    exit_with_error "Système de gestion de paquets non pris en charge"
fi

# Configuration, compilation et installation de PHP
echo "Configuration de PHP..."
cd "$extracted_dir" || exit_with_error "Impossible de se déplacer dans le répertoire d'extraction"
./configure --prefix="$install_dir" --disable-fileinfo || exit_with_error "Échec de la configuration de PHP"
make || exit_with_error "Échec de la compilation de PHP"
sudo make install || exit_with_error "Échec de l'installation de PHP"

# Affichage du chemin vers l'exécutable PHP et la version installée
echo "Installation terminée."
echo "Le chemin vers l'exécutable PHP est : $(which php)"
echo "Version de PHP installée :"
php --version
