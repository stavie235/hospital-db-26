#!/bin/bash
set -euo pipefail

MARKER_FILE="/tmp/hospital-db-init-in-progress"

if [[ -f "${MARKER_FILE}" ]]; then
    exit 1
fi

mysqladmin ping --host=127.0.0.1 --protocol=tcp -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent >/dev/null

mysql --host=127.0.0.1 --protocol=tcp -uroot -p"${MYSQL_ROOT_PASSWORD}" --skip-column-names \
    -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'hospital';" \
    | grep -qx "hospital"
