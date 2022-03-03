#!/bin/sh

ECHO_LINE_BREAK="echo -----------------------------------------------------"

service "$DB_TYPE" start || exit 1

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
