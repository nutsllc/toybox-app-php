#! /bin/sh

. .env

#REPOSITORY_ROOT=$(cd $(dirname $0); pwd)/..
TMP_DIR=${REPOSITORY_ROOT}/tmp

NGINX_ROOT=${REPOSITORY_ROOT}/data/nginx
DOCUMENT_ROOT=${NGINX_ROOT}/html
WP_CONFIG_PATH=${NGINX_ROOT}

function _print_ok() {
    printf 'ok\n'
}

function _prepare() {
    mkdir -p ${NGINX_ROOT} ${DOCUMENT_ROOT}
    [ $(ls ${DOCUMENT_ROOT} | wc -l) -ne 0 ] && {
        echo "DocumentRoot (${DOCUMENT_ROOT}) must be empty."
        exit 1;
    }
    mkdir -p ${TMP_DIR}
    echo '>> start installing WordPress...ok'
}
_prepare

function _download_wordpress() {
    echo ">> download WordPress ${WP_VERSION} ..."
    url="https://wordpress.org/wordpress-${WP_VERSION}.tar.gz"
    curl ${url} -o ${TMP_DIR}/wp.tar.gz
    [ ! -f ${TMP_DIR}/wp.tar.gz ] && {
        echo 'Download error.'
        exit 1
    }
    _print_ok
    printf '>> extract...'
    tar xzf ${TMP_DIR}/wp.tar.gz -C ${TMP_DIR}
    _print_ok
}
_download_wordpress

function _setup_wp_config() {
    printf '>> setting up wp-config.php...'
    . ${REPOSITORY_ROOT}/bin/.env
    WP_CONFIG_FILE=${NGINX_ROOT}/wp-config.php
    cp ${TMP_DIR}/wordpress/wp-config-sample.php ${WP_CONFIG_FILE}

    # DB settings
    sed -i -e "s/\(define( 'DB_NAME', '\)database_name_here\(' );\)/\1${DB_NAME}\2/g" ${WP_CONFIG_FILE}
    sed -i -e "s/\(define( 'DB_USER', '\)username_here\(' );\)/\1${DB_USER}\2/g" ${WP_CONFIG_FILE}
    sed -i -e "s/\(define( 'DB_PASSWORD', '\)password_here\(' );\)/\1${DB_PASSWORD}\2/g" ${WP_CONFIG_FILE}
    sed -i -e "s/\(define( 'DB_HOST', '\)localhost\(' );\)/\1${DB_HOST}\2/g" ${WP_CONFIG_FILE}
    sed -i -e "s/\(\$table_prefix = '\)wp_\(';\)/\1${DB_TABLE_PREFIX}\2/" ${WP_CONFIG_FILE}

    # Random keys
    keys=(
        'AUTH_KEY'
        'SECURE_AUTH_KEY'
        'LOGGED_IN_KEY'
        'NONCE_KEY'
        'AUTH_SALT'
        'SECURE_AUTH_SALT'
        'LOGGED_IN_SALT'
        'NONCE_SALT'
    );

    for key in ${keys[@]}; do
        value=$(openssl rand -hex 64);
        sed -i -e "s/\(define( '${key}',.*'\)put your unique phrase here\(' );\)/\1${value}\2/" ${WP_CONFIG_FILE}
    done

    chmod 400 ${WP_CONFIG_FILE}
    _print_ok
}
_setup_wp_config

function _deploy_wp() {
    printf '>> deploy...'
    mv ${TMP_DIR}/wordpress/* ${DOCUMENT_ROOT}
    find ${DOCUMENT_ROOT} -type d -exec chmod 705 {} +
    find ${DOCUMENT_ROOT} -type f -exec chmod 605 {} +
    rm -rf ${TMP_DIR}
    _print_ok
}
_deploy_wp

# wordpress original
#chmod 644 application/data/nginx/wp-config.php
#find application/data/nginx -type d -exec chmod 755 {} +
#find /path/to/dir -type f -exec chmod 644 {} +

echo 'complete!'
echo "access '${SITE_URL}' on browser. Enjoy :-)"
