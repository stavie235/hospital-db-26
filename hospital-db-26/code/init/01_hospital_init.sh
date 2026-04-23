#!/bin/bash
set -e

echo "[hospital-db] Starting database initialization..."

echo "[hospital-db] Step 1/3: Creating schema (install2.sql)..."
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" --local-infile=1 \
    < /tmp/sql/install2.sql
echo "[hospital-db] Schema ready."

echo "[hospital-db] Step 2/3: Loading reference data (load.sql) — may take several minutes..."
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" --local-infile=1 \
    < /tmp/sql/load.sql
echo "[hospital-db] Reference data loaded."

echo "[hospital-db] Step 3/3: Generating dummy data (dummy_data.sql)..."
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" --local-infile=1 \
    < /tmp/sql/dummy_data.sql
echo "[hospital-db] Dummy data generated."

echo "[hospital-db] All done. Database is ready."
