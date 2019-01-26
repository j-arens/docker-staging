# build off of php with apache image
ARG PHP_VERSION=5.4
FROM php:$PHP_VERSION-apache

# copy files/folders into container
COPY functions.sh /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin

# install vim for dev convenience
# install and setup wp-cli
# install mysql-client for wp-cli
# make entrypoint and functions executable
RUN apt-get update \
    && apt-get install -y vim \
    && apt-get install -y mysql-client zlib1g-dev \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/functions.sh

# install php extensions
RUN docker-php-ext-install zip \
    && docker-php-ext-install mysqli \
    && apt-get install -y libjpeg-dev libpng-dev libfreetype6-dev libmagickwand-dev \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# expose container's port 80
EXPOSE 80

# run when the image starts
ENTRYPOINT ["docker-entrypoint.sh"]
