#!/bin/bash
set -euo pipefail

# setup 
shopt -s expand_aliases
echo 'alias wp="/usr/local/bin/wp --allow-root --path=/var/www/html/${SUBDIR}"' >> ~/.bashrc
echo "source /usr/local/bin/functions.sh" >> ~/.bashrc
source ~/.bashrc

# if wp isn't installed download core, setup config, and install
# if FLUSH_DB do a fresh install
if ! $(wp core is-installed); then
    prepare_wp_install
    install_wp
elif [ $FLUSH_DB ]; then
    install_wp
fi

# run configurations
configure_ini
write_htaccess
configure_apache

# reload apache and run it in the foreground
apachectl -D FOREGROUND

# run passed in commands
exec "$@"
