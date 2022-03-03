ARG BASE_IMAGE
FROM $BASE_IMAGE

RUN set -ex; \
    apt update && \
    apt install -y lsb-release apt-transport-https \
    ca-certificates wget curl git systemd

# INSTALL PYTHON (WITH PIP)
RUN set -ex; \
    apt install -y \
    python3 python3-pip python3-distutils zstd sudo \
    python3 -V

# UPGRADE PIP & INSTALL PYTEST
RUN set -ex && \
    python3 -m pip install -U pip && \
    python3 -m pip install pytest

# INSTALL PHP AND NECESSARY PHP EXTENSIONS
ARG PHP_VERSION
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" \
    | tee /etc/apt/sources.list.d/php.list && apt update
RUN set -ex && \
    apt install -y php$PHP_VERSION php$PHP_VERSION-dom php$PHP_VERSION-zip \
    php$PHP_VERSION-XMLWriter php$PHP_VERSION-XMLReader libxml2 \
    php$PHP_VERSION-mbstring php$PHP_VERSION-GD php$PHP_VERSION-SimpleXML \
    php$PHP_VERSION-curl

# INSTALL COMPOSER
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN sudo php composer-setup.php --install-dir/usr/local/bin --filename=composer

# INSTALL NODEJS & NPM
RUN set -ex; \
    apt install -y npm && \
    sudo curl -sL https://deb.nodesource.com/setup_14.x | bash - && apt update && \
    apt install -y nodejs && \
    npm --version && \
    npm install -g npm@latest && \
    node --version && \
    npm --version

# INSTALL PDO_MYSQL or PDO_PGSQL AND INIT NEXTCLOUD DB
ARG VER
ARG DB_TYPE
ARG NC_CREATE_USER_SQL
COPY $NC_CREATE_USER_SQL /create_user.sql

# RUN set -ex; if [ $DB_TYPE = "mysql" ]; then \
#         sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29 && \
#         wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb && \
#         apt install -y debconf-utils && export DEBIAN_FRONTEND=noninteractive && \
#         bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password password root"' && \
#         bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"' && \
#         debconf-get-selections | grep mysql && \
#         sudo dpkg -i ./mysql-apt-config_0.8.22-1_all.deb \
#         && apt update; \
#     fi

ARG NEXTCLOUD_VERSION
RUN set -ex; \
    DB_PKG=$(echo $DB_TYPE | sed 's/mysql/mariadb-server/') && \
    DB_INIT=$(echo $DB_TYPE | sed 's/mysql/sudo -u root mysql -p/') && \
    DB_PKG=$(echo $DB_PKG | sed 's/pgsql/postgresql/') && \
    DB_INIT=$(echo $DB_INIT | sed 's/pgsql/sudo -u postgres psql/') && \
    sudo apt install -y php$PHP_VERSION-$DB_TYPE $DB_PKG && \
    DB_SERVICE=$(echo $DB_TYPE | sed 's/mysql/mysql/') && \
    DB_SERVICE=$(echo $DB_TYPE | sed 's/pgsql/postgresql/') && \
    if [ $DB_TYPE = "pgsql" ]; then sudo systemctl enable $DB_SERVICE; fi && \
    sudo service $DB_SERVICE start && \
    sudo service $DB_SERVICE restart && \
    ss -tunlp && \
    $DB_INIT < /create_user.sql

# INSTALL NEXTLOUD AND CONFIGURE FOR DEBUGGING
ARG NEXTCLOUD_VERSION
RUN set -ex; ss -tunlp; \
    git clone https://github.com/nextcloud/server.git --recursive --depth 1 -b $NEXTCLOUD_VERSION nextcloud \
    && DB_SERVICE=$(echo $DB_TYPE | sed 's/mysql/mysql/') \
    && DB_SERVICE=$(echo $DB_TYPE | sed 's/pgsql/postgresql/') \
    && sudo service $DB_SERVICE start \
    && ss -tunlp \
    && php -f nextcloud/occ maintenance:install --database-host localhost --database-name nextcloud --database-user nextcloud --database-pass nextcloud --admin-user admin --admin-pass admin --database $DB_TYPE \
    && php -f nextcloud/occ config:system:set debug --type bool --value true \
    && mkdir -p nextcloud/data/appdata_$(php -f nextcloud/occ config:system:get instanceid)/cloud_py_api/cloud_py_api \
    && git clone https://github.com/nextcloud/serverinfo.git --depth 1 -b $NEXTCLOUD_VERSION nextcloud/apps/serverinfo \
    && php -f nextcloud/occ app:enable serverinfo \
    && git clone https://github.com/bigcat88/cloud_py_api.git nextcloud/apps/cloud_py_api \
    && cd nextcloud/apps/cloud_py_api && composer install && npm install \
    && cd / && \
    php -f nextcloud/occ app:enable cloud_py_api

ARG ENTRY_POINT
COPY $ENTRY_POINT /entrypoint.sh

RUN chmod +x /entrypoint.sh;

ENV DB_TYPE $DB_TYPE
CMD ["sh", "-c", "/entrypoint.sh"]
