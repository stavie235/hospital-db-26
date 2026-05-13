# Hospital DB — Integration Tests

These tests verify that all **triggers** and **indexes** defined in `install.sql` work correctly against a live MariaDB instance.

## Prerequisites

1. Docker and `docker compose` installed.
2. Python 3.9+ with `pip`.

## Setup

```bash
# 1. Start the database
cd hospital-db-26/code
docker compose up -d

# 2. Wait until healthy (first run loads data — takes ~2 min)
docker compose ps   # wait until Status = healthy

# 3. Install test dependencies
pip install -r hospital-db-26/tests/requirements.txt

# 4. Run all tests
cd hospital-db-26
pytest tests/ -v
```

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `HOSPITAL_DB_HOST` | `127.0.0.1` | MariaDB host |
| `HOSPITAL_DB_PORT` | `3307` | External mapped port |
| `HOSPITAL_DB_USER` | `root` | DB user |
| `HOSPITAL_DB_PASSWORD` | `root` | DB password |
| `HOSPITAL_DB_NAME` | `hospital` | Database name |

## Test files

| File | What it tests |
|---|---|
| `test_indexes.py` | All 25 indexes exist in `information_schema`; all 19 triggers registered |
| `test_triggers_doctor.py` | Supervisor rules + cycle detection |
| `test_triggers_prescriptions.py` | Allergy check on prescription |
| `test_triggers_shifts.py` | Monthly limits, rest period, consecutive nights, trainee senior, min staffing |
| `test_triggers_procedures.py` | Room overlap, surgeon overlap, assistant overlap |
| `test_triggers_beds.py` | Bed availability check, status lifecycle, cost calculation |
| `test_triggers_evaluations.py` | Evaluation on discharged hospitalization; doctor evaluation rules |

## Design notes

- Each test uses the `cur` fixture from `conftest.py`, which **rolls back** after the test — the database is left unchanged.
- `helpers.py` provides small insert helpers so tests read like specifications, not SQL.
- Tests only use the public schema interface (INSERT/UPDATE/DELETE on real tables). No mocking.
