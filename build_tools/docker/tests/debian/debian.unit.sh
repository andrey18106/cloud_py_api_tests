#!/bin/sh

ECHO_LINE_BREAK="echo -----------------------------------------------------"

if [ "$DB_TYPE" = "pgsql" ]; then \
    service postgresql start || exit 1;
elif [ "$DB_TYPE" = "mysql" ]; then \
    service mysql start || exit 1;
fi

$ECHO_LINE_BREAK
echo "PHP UNIT TESTS START"
$ECHO_LINE_BREAK

cd nextcloud/apps/cloud_py_api || exit
composer install
composer test:unit || exit 1

$ECHO_LINE_BREAK
echo "PHP UNIT TESTS END"
$ECHO_LINE_BREAK


$ECHO_LINE_BREAK
echo "JavaScript UNIT TESTS START"
$ECHO_LINE_BREAK

cd nextcloud/apps/cloud_py_api || exit
npm run test || exit 1

$ECHO_LINE_BREAK
echo "JavaScript UNIT TESTS END"
$ECHO_LINE_BREAK

exit 0
