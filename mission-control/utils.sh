#!/bin/bash

_mc_verify_args () {
    for var in "$@"; do
        if [ -n "$var" ]; then
            echo >&2 "Missing required arguments"
            exit 1
        fi
    done 
}

mc_build_deploy_path () {
    local branch="$1"
    local sha="${2:-}"
    if [ -z "$sha" ]; then
        echo "${DEPLOY_BASE}/${branch}"
    else
        echo "${DEPLOY_BASE}/${branch}/${sha}"
    fi
}

mc_build_public_url () {
    local domain="$1"
    local branch="$2"
    local user="$3"
    echo "${STAGING_PROTOCOL}://${domain}/${branch}/${user}"
}

mc_build_service_url () {
    local service="$1"
    local port="${2:-80}"
    echo "${STAGING_PROTOCOL}://${service}:${port}"
}

mc_build_service_name () {
    local sha="$1"
    local user="$2"
    local service="${3:-}"
    if [ -z "$service" ]; then
        echo "${sha}_${user}"
    else
        echo "${sha}_${user}_${service}"
    fi
}

mc_build_proxy_conf_path () {
    local sha="$1"
    local user="$2"
    echo "${PROXIES_BASE}/commit-${sha}-${user}.conf"
}
