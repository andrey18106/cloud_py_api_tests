docker build -t cpa_debian_mysql_test ./debian/ \
--build-arg OS=debian \
--build-arg VER=10.11 \
--build-arg BASE_IMAGE=debian:10.11 \
--build-arg ENTRY_POINT=debian.integration.sh \
--build-arg NEXTCLOUD_VERSION=v22.2.5 \
--build-arg NC_CREATE_USER_SQL=mysql_create_user.sql \
--build-arg PHP_VERSION=7.4 \
--build-arg DB_TYPE=mysql
