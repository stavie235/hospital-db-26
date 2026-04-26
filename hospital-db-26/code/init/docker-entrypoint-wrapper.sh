#!/bin/bash
set -euo pipefail

ORIGINAL_ENTRYPOINT="/usr/local/bin/docker-entrypoint.sh"
EXPECTED_HASH_FILE="/opt/hospital-db/sql.sha256"
APPLIED_HASH_FILE="/var/lib/mysql/.hospital-db-sql.sha256"
RELOAD_MODE="${HOSPITAL_DB_RELOAD_MODE:-preserve}"
SERVER_PID=""

has_existing_data() {
    [[ -d /var/lib/mysql/mysql ]]
}

normalize_reload_mode() {
    case "${RELOAD_MODE}" in
        preserve|checksum|force)
            ;;
        *)
            echo "[hospital-db] Unsupported HOSPITAL_DB_RELOAD_MODE='${RELOAD_MODE}'. Use preserve, checksum, or force." >&2
            exit 1
            ;;
    esac
}

should_reload_existing_data() {
    case "${RELOAD_MODE}" in
        preserve)
            return 1
            ;;
        force)
            return 0
            ;;
        checksum)
            if [[ ! -f "${APPLIED_HASH_FILE}" ]]; then
                return 0
            fi

            if cmp -s "${EXPECTED_HASH_FILE}" "${APPLIED_HASH_FILE}"; then
                return 1
            fi

            return 0
            ;;
    esac
}

wait_for_server() {
    local attempt=0

    until mysqladmin ping --host=127.0.0.1 --protocol=tcp -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent >/dev/null 2>&1; do
        if [[ -n "${SERVER_PID}" ]] && ! kill -0 "${SERVER_PID}" 2>/dev/null; then
            echo "[hospital-db] MariaDB exited before it became ready." >&2
            return 1
        fi

        attempt=$((attempt + 1))
        if (( attempt >= 60 )); then
            echo "[hospital-db] Timed out waiting for MariaDB to accept connections." >&2
            return 1
        fi

        sleep 2
    done
}

stop_server() {
    if [[ -n "${SERVER_PID}" ]] && kill -0 "${SERVER_PID}" 2>/dev/null; then
        kill -TERM "${SERVER_PID}" 2>/dev/null || true
        wait "${SERVER_PID}" || true
    fi
}

trap stop_server SIGINT SIGTERM

normalize_reload_mode

if ! has_existing_data; then
    export HOSPITAL_DB_FIRST_RUN=true
    echo "[hospital-db] No persisted database found. Running first-time initialization."
    exec "${ORIGINAL_ENTRYPOINT}" "$@"
fi

export HOSPITAL_DB_FIRST_RUN=false

if ! should_reload_existing_data; then
    echo "[hospital-db] Using persisted database from /var/lib/mysql (reload mode: ${RELOAD_MODE})."
    exec "${ORIGINAL_ENTRYPOINT}" "$@"
fi

echo "[hospital-db] Existing database detected. Reload requested (mode: ${RELOAD_MODE})."
"${ORIGINAL_ENTRYPOINT}" "$@" &
SERVER_PID="$!"

if ! wait_for_server; then
    stop_server
    exit 1
fi

if ! /docker-entrypoint-initdb.d/01_hospital_init.sh; then
    echo "[hospital-db] Reload failed. Stopping MariaDB so the container exits cleanly." >&2
    stop_server
    exit 1
fi

echo "[hospital-db] Reload complete. MariaDB will continue serving with the refreshed dataset."
wait "${SERVER_PID}"
