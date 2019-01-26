# write htaccess configured for pretty permalinks
write_htaccess () {
    local file=/var/www/html/${SUBDIR}/.htaccess
    if [ ! -e $file ]; then
        cat > $file <<-EOF
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /${SUBDIR}/
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /${SUBDIR}/index.php [L]
</IfModule>
# END WordPress
EOF
    fi
}

# configure php ini settings
configure_ini () {
    if ! [ -e /usr/local/etc/php/conf.d/p7-staging.ini ]; then
        touch /usr/local/etc/php/conf.d/p7-staging.ini

        SETTINGS[0]="upload_max_filesize=100M"
        SETTINGS[1]="post_max_size=100M"

        for i in "${SETTINGS[@]}"; do
            echo $i >> /usr/local/etc/php/conf.d/p7-staging.ini
        done
    fi
}

# give apache ownership and ensure rewrite mod is enabled
configure_apache () {
    chown -R www-data:www-data /var/www/html/${SUBDIR}/wp-content/uploads
    chown www-data:www-data /var/www/html/${SUBDIR}/.htaccess
    a2enmod rewrite
}

# download wp core, create and setup config file
prepare_wp_install () {
    wp core download --version=latest --force

    wp config create \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --extra-php="define('WP_DEBUG', ${WP_DEBUG});"

    wp config set WP_SITEURL ${WP_URL} --type=constant 
    wp config set WP_HOME ${WP_URL} --type=constant
}

# run wp install process
install_wp () {
    if [ $FLUSH_DB ]; then
        wp db reset --yes
    fi

    wp core install \
        --url=${WP_URL} \
        --title=staging \
        --admin_user=admin \
        --admin_password=z \
        --admin_email=josh@pro.photo \
        --skip-email

    wp rewrite structure '/%postname%/'
}
