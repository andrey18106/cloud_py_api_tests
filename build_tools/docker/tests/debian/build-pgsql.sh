docker build -t cpa_debian_pgsql_test ./debian/ \
--build-arg BASE_IMAGE=debian:10.11 \
--build-arg ENTRY_POINT=debian.integration.sh \
--build-arg NEXTCLOUD_VERSION=v23.0.2 \
--build-arg NC_CREATE_USER_SQL=pgsql_create_user.sql \
--build-arg PHP_VERSION=7.4 \
--build-arg DB_TYPE=pgsql
