# Hospital DB — Docker Setup

## Overview

This setup fully automates the database lifecycle through Docker Compose:
schema creation → reference data loading → dummy data generation.
No manual SQL execution is needed.

---

## Directory Structure

```
hospital-db-26/
├── code/
│   ├── docker-compose1.yml       ← entry point: run this
│   ├── Dockerfile                ← builds mariadb:10.6 + init script
│   ├── init/
│   │   └── 01_hospital_init.sh  ← orchestrates the 3 SQL files
│   └── DOCKER_SETUP.md          ← this file
├── docs/
│   ├── icd10_data.csv           (11,009 rows)
│   ├── ken-codes-clean.csv      (694 rows)
│   ├── lab_test_catalog.csv     (4,062 rows)
│   ├── procedure_catalog.csv    (6,429 rows)
│   ├── drug-description.csv     (88,918 rows)  ← was drug_data-2.csv
│   ├── substance_data-2.csv     (13,933 rows)
│   └── drug_substance_data-2.csv (148,189 rows)
└── sql/
    ├── install2.sql             ← schema: tables, triggers, indexes
    ├── load.sql                 ← reference data: CSV bulk loads
    └── dummy_data.sql           ← operational data: stored procedure
```

---

## How to Run

### First start (builds image + initializes DB)

```bash
cd hospital-db-26/code
docker compose -f docker-compose1.yml up --build
```

Initialization runs automatically and takes **3–8 minutes** depending on hardware
(the drug/substance CSVs total ~250k rows).

Watch progress in the logs:

```
[hospital-db] Step 1/3: Creating schema (install2.sql)...
[hospital-db] Step 2/3: Loading reference data (load.sql) — may take several minutes...
[hospital-db] Step 3/3: Generating dummy data (dummy_data.sql)...
[hospital-db] All done. Database is ready.
```

### Subsequent starts (data already persisted in volume)

```bash
docker compose -f docker-compose1.yml up
```

Init scripts are skipped — the volume already has data.

### Stop (keep data)

```bash
docker compose -f docker-compose1.yml down
```

### Full reset (destroy data, re-initialize from scratch)

```bash
docker compose -f docker-compose1.yml down -v
docker compose -f docker-compose1.yml up --build
```

### Connect with a MySQL client

```
Host:     127.0.0.1
Port:     3307
User:     root
Password: root
Database: hospital
```

Or via Docker directly:

```bash
docker exec -it hospital_db mariadb -uroot -proot hospital
```

---

## What Runs and in What Order

### 1. `install2.sql`

- `DROP DATABASE IF EXISTS hospital` — always starts clean
- `CREATE DATABASE hospital CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
- Creates all tables in dependency order (staff hierarchy → departments → patients → hospitalizations → drugs/prescriptions)
- Installs **14 triggers** (allergy checks, shift rules, bed management, cost calculation, etc.)
- Creates **13 indexes** for query performance

### 2. `load.sql`

Bulk-loads reference data from CSVs mounted at `/tmp/docs/`:

| Table              | Source CSV                  | Rows    |
|--------------------|-----------------------------|---------|
| `ICD10`            | `icd10_data.csv`            | 11,009  |
| `procedure_catalog`| `procedure_catalog.csv`     | 6,429   |
| `lab_test_catalog` | `lab_test_catalog.csv`      | 4,062   |
| `ken`              | `ken-codes-clean.csv`       | 694     |
| `drug`             | `drug-description.csv` *    | 88,918  |
| `active_substance` | `substance_data-2.csv`      | 13,933  |
| `drug_substance`   | `drug_substance_data-2.csv` | 148,189 |

\* `load.sql` references `drug_data-2.csv` (old name). The docker-compose mounts
`drug-description.csv` at that path as an alias so the SQL file needs no modification.

### 3. `dummy_data.sql`

Calls the stored procedure `generate_dummy_data()` which inserts deterministic
test data into all operational tables:

| Entity               | Count |
|----------------------|-------|
| Departments          | 15    |
| Doctors              | 80    |
| Nurses               | 120   |
| Administrative staff | 60    |
| Beds                 | 300   |
| Procedure rooms      | 10    |
| Patients             | 200   |
| Hospitalizations     | 500   |
| Triage records       | 280   |
| Prescriptions        | 300   |
| Lab tests            | 200   |
| Medical procedures   | 150   |

---

## How the Docker Setup Works

### Dockerfile

```dockerfile
FROM mariadb:10.6
COPY --chmod=755 init/01_hospital_init.sh /docker-entrypoint-initdb.d/
```

The init script is **baked into the image** with executable permissions.
This is necessary on Windows, where bind-mounted files do not inherit Unix
execute bits — making the script non-executable and silently skipped by
the MariaDB entrypoint.

### docker-compose1.yml — key settings

| Setting | Reason |
|---|---|
| `build:` instead of `image:` | Uses the Dockerfile above |
| `--secure-file-priv=` | Allows `LOAD DATA INFILE` to read from `/tmp/docs/` |
| `--local-infile=1` | Enables `LOCAL` infile on the client (belt-and-suspenders) |
| `--max_allowed_packet=256M` | Prevents packet errors on large CSV rows |
| `--character-set-server=utf8mb4` | Greek text support |
| `../docs/drug-description.csv:/tmp/docs/drug_data-2.csv:ro` | Alias for renamed file |
| `../sql:/tmp/sql:ro` | SQL files accessible to init script |
| `healthcheck` | Reports when InnoDB is fully initialized |
| `name: hospital_db_data` | Named volume so it survives `down` without `-v` |

### MariaDB entrypoint behavior

On first start (empty data volume), MariaDB runs every file inside
`/docker-entrypoint-initdb.d/` in alphabetical order:

- `.sh` files → executed as shell scripts
- `.sql` files → piped through the mysql client

Our single `.sh` script runs the three SQL files manually so it controls
connection flags (`--local-infile=1`) and execution order.
On subsequent starts the volume is non-empty and init is skipped entirely.

---

## Known Issues & Design Decisions

### drug_data-2.csv rename
`load.sql` line 43 references `drug_data-2.csv`, which was deleted from the repo
and replaced by `drug-description.csv` (identical schema: `drug_name, description`).
**Fix**: a second bind mount in docker-compose aliases the new file at the old path.
The SQL file is left untouched.

### secure_file_priv
`load.sql` uses `LOAD DATA INFILE` (server-side). MariaDB's default
`secure_file_priv` can block reads from arbitrary paths.
Setting `--secure-file-priv=` (empty) removes the restriction inside
the container, which is acceptable for a development database.

### Shift staffing minimum not enforced by triggers
Per the project specification, the rule requiring ≥3 doctors, ≥6 nurses,
and ≥2 administrative staff per shift is **not** a database trigger — it
is enforced at the application layer only.

### Greek locale
All enum values, trigger error messages, and dummy data are in Greek (UTF-8).
Ensure your client is configured for `utf8mb4` to display them correctly.

---

## Troubleshooting

**Init did not run (DB is empty)**
The volume already existed. Run `docker compose -f docker-compose1.yml down -v`
then `up --build` to start fresh.

**`LOAD DATA INFILE` permission denied**
Ensure `--secure-file-priv=` is in the command list and the container was
rebuilt after adding it (`docker compose -f docker-compose1.yml up --build`).

**Port conflict**
The host port is already mapped to 3307 (`"3307:3306"`). If 3307 is also taken,
change it to any free port (e.g. `"3308:3306"`) and connect on that port.

**Init script not found or not executable**
Rebuild the image: `docker compose -f docker-compose1.yml build --no-cache`.
The Dockerfile's `COPY --chmod=755` must be in a BuildKit-capable Docker version
(Docker Desktop ≥ 20.10).
