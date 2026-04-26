#!/bin/bash
set -euo pipefail

SQL_DIR="/opt/hospital-db/sql"
EXPECTED_HASH_FILE="/opt/hospital-db/sql.sha256"
APPLIED_HASH_FILE="/var/lib/mysql/.hospital-db-sql.sha256"
MARKER_FILE="/tmp/hospital-db-init-in-progress"

trap 'rm -f "${MARKER_FILE}"' EXIT
touch "${MARKER_FILE}"

run_sql() {
    local sql_file="$1"
    mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" --local-infile=1 < "${sql_file}"
}

echo "[hospital-db] Starting database initialization..."

echo "[hospital-db] Step 1/2: Creating schema (install.sql)..."
run_sql "${SQL_DIR}/install.sql"
echo "[hospital-db] Schema ready."

echo "[hospital-db] Step 2/2: Loading reference and sample data (load.sql)..."
run_sql "${SQL_DIR}/load.sql"
echo "[hospital-db] Reference and sample data loaded."

cp "${EXPECTED_HASH_FILE}" "${APPLIED_HASH_FILE}"
echo "[hospital-db] Applied SQL fingerprint recorded at ${APPLIED_HASH_FILE}."
echo "[hospital-db] All done. Database is ready."
