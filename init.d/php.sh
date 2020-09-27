#!/bin/bash

set -e

init_process() {
    if [[ -n "${PHP_FPM_CONF}" ]]; then
        sed -i "s/\$PHP_MAX_CHILDREN/${PHP_MAX_CHILDREN}/" $PHP_FPM_CONF
        sed -i "s/\$PHP_START_SERVERS/${PHP_START_SERVERS}/" $PHP_FPM_CONF
        sed -i "s/\$PHP_MIN_SPARE_SERVERS/${PHP_MIN_SPARE_SERVERS}/" $PHP_FPM_CONF
        sed -i "s/\$PHP_MAX_SPARE_SERVERS/${PHP_MAX_SPARE_SERVERS}/" $PHP_FPM_CONF
        sed -i "s/\$PHP_FPM_LISTEN/${PHP_FPM_LISTEN}/" $PHP_FPM_CONF
    fi
}

disable_modules() {
    if [[ -n "${PHP_EXTENSIONS_DISABLE}" ]]; then
        for module in $(echo ${PHP_EXTENSIONS_DISABLE} | sed "s/,/ /g")
        do
            if [[ -f "${PHP_INI_CONF_DIR}/${module}.ini" ]]; then
                phpdismod ${module}
            else
                echo "WARNING: instructed to disable module ${module} but it was not found"
            fi
        done
    fi
}


init_process
disable_modules