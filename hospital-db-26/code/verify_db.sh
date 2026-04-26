#!/bin/bash
set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-mariadb}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

if ! command -v docker >/dev/null 2>&1; then
    echo "docker is required to run this verification script." >&2
    exit 1
fi

if ! docker compose -f "${COMPOSE_FILE}" ps "${SERVICE_NAME}" >/dev/null 2>&1; then
    echo "Service '${SERVICE_NAME}' is not available in ${COMPOSE_FILE}." >&2
    exit 1
fi

if [[ -z "$(docker compose -f "${COMPOSE_FILE}" ps -q "${SERVICE_NAME}")" ]]; then
    echo "Service '${SERVICE_NAME}' is not running. Start it first with 'docker compose up -d'." >&2
    exit 1
fi

docker compose -f "${COMPOSE_FILE}" exec -T "${SERVICE_NAME}" \
    mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" --table <<'SQL'
SELECT 'hospital schema exists' AS check_name,
       IF(EXISTS (
           SELECT 1
           FROM information_schema.schemata
           WHERE schema_name = 'hospital'
       ), 'yes', 'no') AS result;

USE hospital;

SELECT 'table_count' AS metric, COUNT(*) AS value
FROM information_schema.tables
WHERE table_schema = 'hospital';

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'hospital'
ORDER BY table_name;

SELECT table_name, expected_rows, actual_rows,
       CASE
           WHEN expected_rows IS NULL THEN 'info'
           WHEN expected_rows = actual_rows THEN 'ok'
           ELSE 'mismatch'
       END AS status
FROM (
    SELECT 'ICD10' AS table_name, NULL AS expected_rows, COUNT(*) AS actual_rows FROM ICD10
    UNION ALL
    SELECT 'active_substance', NULL, COUNT(*) FROM active_substance
    UNION ALL
    SELECT 'administrative', 60, COUNT(*) FROM administrative
    UNION ALL
    SELECT 'bed', 300, COUNT(*) FROM bed
    UNION ALL
    SELECT 'department', 15, COUNT(*) FROM department
    UNION ALL
    SELECT 'doctor', 80, COUNT(*) FROM doctor
    UNION ALL
    SELECT 'doctor_evaluation', 250, COUNT(*) FROM doctor_evaluation
    UNION ALL
    SELECT 'drug', NULL, COUNT(*) FROM drug
    UNION ALL
    SELECT 'drug_substance', NULL, COUNT(*) FROM drug_substance
    UNION ALL
    SELECT 'evaluation', 320, COUNT(*) FROM evaluation
    UNION ALL
    SELECT 'hospitalization', 500, COUNT(*) FROM hospitalization
    UNION ALL
    SELECT 'ken', NULL, COUNT(*) FROM ken
    UNION ALL
    SELECT 'lab_test', 200, COUNT(*) FROM lab_test
    UNION ALL
    SELECT 'lab_test_catalog', NULL, COUNT(*) FROM lab_test_catalog
    UNION ALL
    SELECT 'medical_procedure', 150, COUNT(*) FROM medical_procedure
    UNION ALL
    SELECT 'nurse', 120, COUNT(*) FROM nurse
    UNION ALL
    SELECT 'patient', 200, COUNT(*) FROM patient
    UNION ALL
    SELECT 'patient_allergy', NULL, COUNT(*) FROM patient_allergy
    UNION ALL
    SELECT 'prescription', 300, COUNT(*) FROM prescription
    UNION ALL
    SELECT 'procedure_catalog', NULL, COUNT(*) FROM procedure_catalog
    UNION ALL
    SELECT 'procedure_assistant', 300, COUNT(*) FROM procedure_assistant
    UNION ALL
    SELECT 'procedure_room', 10, COUNT(*) FROM procedure_room
    UNION ALL
    SELECT 'shift', NULL, COUNT(*) FROM shift
    UNION ALL
    SELECT 'shift_assignment', NULL, COUNT(*) FROM shift_assignment
    UNION ALL
    SELECT 'staff', 260, COUNT(*) FROM staff
    UNION ALL
    SELECT 'triage_record', 280, COUNT(*) FROM triage_record
) AS counts
ORDER BY table_name;

SELECT staff_id, first_name, last_name, staff_type
FROM staff
ORDER BY staff_id
LIMIT 5;

SELECT patient_id, first_name, last_name, insurance_provider
FROM patient
ORDER BY patient_id
LIMIT 5;

SELECT department_id, name, num_beds
FROM department
ORDER BY department_id
LIMIT 5;
SQL
