#!/bin/sh

ECHO_LINE_BREAK="echo -----------------------------------------------------"

if [ "$DB_TYPE" = "pgsql" ]; then \
    service postgresql start || exit 1;
elif [ "$DB_TYPE" = "mysql" ]; then \
    service mysql start || exit 1;
fi

$ECHO_LINE_BREAK
echo "PHP INTEGRATION TESTS START"
$ECHO_LINE_BREAK

cd nextcloud/apps/cloud_py_api || exit
composer install
composer test:integration || exit 1

$ECHO_LINE_BREAK
echo "PHP INTEGRATION TESTS END"
$ECHO_LINE_BREAK

exit 0
