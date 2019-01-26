#!/bin/bash

DEPLOY_BASE=~/builds
PROXIES_BASE=~/proxies

COMPOSE_STAGING_NGINX=~/compose/staging-nginx.yml
COMPOSE_STAGING_WP=~/compose/staging-wordpress.yml

STAGING_PROTOCOL="http"
THEME="prophoto7"

TEMPLATES_DIR=~/mission-control/templates

source ~/mission-control/utils.sh

mc_init_staging () {
    echo "source ~/mission-control/houston.sh" >> ~/.bashrc
    source ~/.bashrc
    apt-get update
    apt-get install -y unzip
    mkdir ${DEPLOY_BASE} ${PROXIES_BASE}
    docker-compose -f ${COMPOSE_STAGING_NGINX} up -d
}

mc_create_deploy_dir () {
    local branch="$1"
    local sha="$2"
    mkdir -p $(mc_build_deploy_path $branch $sha)
}

mc_remove_deploy_dir () {
    local branch="$1"
    local sha="${2:-}"
    if [ -z "$sha" ]; then
        rm -rf $(mc_build_deploy_path $branch $sha)
    else
        rm -rf $(mc_build_deploy_path $branch)
    fi
}

mc_unzip_artifact () {
    local branch="$1"
    local sha="$2"
    local file="$3"
    local path=$(mc_build_deploy_path $branch $sha)
    unzip -o "${path}/${file}.zip" -d "${path}/"
}

mc_update_p7_semver () {
    local branch="$1"
    local sha="$2"
    local semver="$3"
    local path=$(mc_build_deploy_path $branch $sha)
    sed -i  "s/7.[[:digit:]].[[:digit:]]*/${semver}/g" ${path}/prophoto7/version.php
}

mc_create_wp_service () {
    local domain="$1"
    local branch="$2"
    local sha="$3"
    local user="$4"
    SUBDIR="${branch}/${user}"
    P7_BUILD="$(mc_build_deploy_path "$branch" "$sha")/${THEME}"
    WP_URL="$(mc_build_public_url "$domain" "$branch" "$user")"
    COMPOSE_PROJECT_NAME="$(mc_build_service_name "$sha" "$user")"
    export SUBDIR P7_BUILD WP_URL COMPOSE_PROJECT_NAME \
        && docker-compose -f ${COMPOSE_STAGING_WP} up -d
}

mc_stop_wp_service () {
    local sha="$1"
    local user="$2"
    local wp=$(mc_build_service_name $sha $user 'wordpress')
    local pma=$(mc_build_service_name $sha $user 'phpmyadmin')
    local db=$(mc_build_service_name $sha $user 'db')
    docker stop ${wp} ${pma} ${db}
}

mc_exec_service () {
    local service="$1"
    local command="$2"
    docker exec -d ${service} ${command}
}

mc_service_cp () {
    local from="$1"
    local to="$2"
    docker cp ${from} ${to}
}

mc_create_proxy_conf () {
    local domain="$1"
    local branch="$2"
    local sha="$3"
    local user="$4"
    local file=$(mc_build_proxy_conf_path $sha $user)
    local template="${TEMPLATES_DIR}/proxy-location.conf"
    local service=$(mc_build_service_name $sha $user 'wordpress')
    touch ${file}
    location="/${branch}/${user}/" \
    proxy_url="$(mc_build_service_url $service)${location}" \
    envsubst '\$location \$proxy_url' < $template > $file
}

mc_remove_proxy_conf () {
    local sha="$1"
    local user="$2"
    local file=$(mc_build_proxy_conf_path $sha $user)
    rm ${file}
}

mc_remove_deploy () {
    local branch="$1"
    local sha="${2:-}"
    local user="${3:-}"
    if [ -z "$sha" ]; then
        rm -rf "${DEPLOY_BASE}/${branch}"
    elif [ -z "$user" ]; then
        rm -rf "${DEPLOY_BASE}/${branch}/${sha}"
    else
        rm -rf "${DEPLOY_BASE}/${branch}/${sha}/${user}"
    fi
}

mc_reload_nginx () {
    docker exec -d staging_nginx nginx -s reload
}

mc_prune_services () {
    docker system prune -f
}
