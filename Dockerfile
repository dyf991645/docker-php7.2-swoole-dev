FROM itfarm/workspace:baseimage-0.11

ENV PHP_INI_CONF_DIR='/etc/php/7.2/mods-available' \
    PHP_MAX_CHILDREN=5 \
    PHP_START_SERVERS=2 \
    PHP_MIN_SPARE_SERVERS=1 \
    PHP_MAX_SPARE_SERVERS=3 \
    PHP_FPM_CONF='/etc/php/7.2/fpm/php-fpm.conf' \
    PHP_FPM_CONF_DIR='/etc/php/7.2/fpm/pool.d' \
    # disable ext by default
    PHP_EXTENSIONS_DISABLE="" \
    PHP_FPM_LISTEN=9000

RUN sed -i 's/ports.ubuntu.com/mirror.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN set -eux \
    && apt-get update && apt-get upgrade -y \
    && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
    && buildDeps='php-pear php7.2-dev g++ re2c make' \
    && apt-get update && apt-get install -y \
    snmp \
    ca-certificates \
    curl \
    xz-utils \
    php7.2-bcmath \
    php7.2-bz2 \
    php7.2-cli \
    php7.2-common \
    php7.2-curl \
    php7.2-dba \
    php7.2-enchant \
    php7.2-fpm \
    php7.2-gd \
    php7.2-gmp \
    php7.2-imap \
    php7.2-interbase \
    php7.2-intl \
    php7.2-json \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-odbc \
    php7.2-opcache \
    php7.2-pgsql \
    php7.2-phpdbg \
    php7.2-pspell \
    php7.2-readline \
    php7.2-recode \
    php7.2-snmp \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-sybase \
    php7.2-tidy \
    php7.2-xml \
    php7.2-xmlrpc \
    php7.2-xsl \
    php7.2-zip \
    php7.2-sockets \
    php7.2-sysvmsg \
    php7.2-sysvsem \
    php7.2-sysvshm \
    php-amqp \
    php-apcu \
    php-apcu-bc \
    php-ds \
    php-gearman \
    php-geoip \
    php-gnupg \
    php-igbinary \
    php-imagick \
    php-lua \
    php-mailparse \
    php-memcache \
    php-memcached \
    php-mongodb \
    php-msgpack \
    php-oauth \
    php-phalcon \
    php-pinba \
    php-propro \
    php-ps \
    php-radius \
    php-raphf \
    php-redis \
    php-rrd \
    php-sass \
    php-smbclient \
    php-solr \
    php-ssh2 \
    php-stomp \
    php-tideways \
    php-uuid \
    php-yaml \
    php-zmq \
    $buildDeps \
    libz-dev \
    libssl-dev \
    libnghttp2-dev \
    libpcre3-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    openssl \
    build-essential \
    && update-alternatives --set php /usr/bin/php7.2 \
    && ln -s /usr/sbin/php-fpm7,2 /usr/sbin/php-fpm \
    && pecl install rar \
    && pecl install swoole \
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV APP_ENV=${app_env:-"prod"} \
    TIMEZONE=${timezone:-"Asia/Shanghai"} \
    PHPREDIS_VERSION=5.1.0 \
    SWOOLE_VERSION=4.4.17 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    ENVIRONMENT=development

# modify php.ini
RUN set -eux \
    && { \
    echo "date.timezone = Asia/Shanghai"; \
    echo "log_errors = On"; \
    echo "memory_limit = 128M"; \
    echo "upload_max_filesize = 20M"; \
    echo "post_max_size = 20M"; \
    echo "session.cookie_httponly = 1"; \
    } | tee ${PHP_INI_CONF_DIR}/zz_ext.ini \
    && { \
    echo "extension=rar.so"; \
    echo "extension=swoole.so"; \
    } | tee ${PHP_INI_CONF_DIR}/rar.ini \
    && phpenmod zz_ext rar

# modify php-fpm.conf
ADD php-fpm.conf ${PHP_FPM_CONF}
RUN rm -f ${PHP_FPM_CONF_DIR}/*

# composer
COPY composer /usr/local/bin/composer
# phinx
COPY phinx /usr/local/bin/phinx

COPY init.d /etc/my_init.d

EXPOSE 22 9000

WORKDIR /opt/ci123/www/html