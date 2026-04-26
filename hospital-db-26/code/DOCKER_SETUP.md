# Hospital DB - Docker Setup

## Overview

This Docker setup runs two services:

- `mariadb`: the hospital database
- `query-ui`: the read-only browser query console

The MariaDB image already contains:

- the schema script: `sql/install.sql`
- the data-loading script: `sql/load.sql`
- all CSV reference datasets from `docs/*.csv`

No manual SQL execution is needed.

The database data is persisted in the named Docker volume `hospital_db_data`,
so normal restarts reuse the existing data by default.

## Directory Structure

```text
hospital-db-26/
├── .dockerignore
├── code/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── DOCKER_SETUP.md
│   ├── query_ui/
│   │   ├── Dockerfile
│   │   ├── server.py
│   │   ├── saved_queries.py
│   │   └── static/
│   └── init/
│       ├── 01_hospital_init.sh
│       ├── docker-entrypoint-wrapper.sh
│       └── hospital-db-healthcheck.sh
├── docs/
│   ├── drug_data-2.csv
│   ├── drug_substance_data-2.csv
│   ├── icd10_data.csv
│   ├── ken-codes-clean.csv
│   ├── lab_test_catalog.csv
│   ├── procedure_catalog.csv
│   └── substance_data-2.csv
└── sql/
    ├── install.sql
    └── load.sql
```

## How to Run

### 1. First start

From the `code/` directory:

```bash
cd hospital-db-26/hospital-db-26/code
docker compose up --build
```

What happens on the first run:

1. Docker builds the MariaDB and query UI images.
2. MariaDB starts with an empty volume.
3. `install.sql` creates the `hospital` schema.
4. `load.sql` loads the CSV reference data and generates the sample operational data.
5. After the database is healthy, the query UI starts.

Initialization can take a few minutes.

Expected log messages:

```text
[hospital-db] No persisted database found. Running first-time initialization.
[hospital-db] Starting database initialization...
[hospital-db] Step 1/2: Creating schema (install.sql)...
[hospital-db] Step 2/2: Loading reference and sample data (load.sql)...
[hospital-db] All done. Database is ready.
```

### 2. Normal restart

```bash
docker compose up
```

This reuses the existing `hospital_db_data` volume and does not reload the SQL.
The UI will be available at:

```text
http://127.0.0.1:8765
```

### 3. Stop the container

```bash
docker compose down
```

This stops the container and keeps the database volume.

### 4. Full reset

Use this when you want to destroy everything and reinitialize from scratch:

```bash
docker compose down -v
docker compose up --build
```

### 5. Verify the loaded contents

After the container is up, run:

```bash
./verify_db.sh
```

The script connects to the running MariaDB container and prints:

- whether the `hospital` schema exists
- the number of tables in the schema
- the full table list
- row counts for the main reference and sample-data tables
- a few sample rows from `staff`, `patient`, and `department`

### 6. Query UI

The query UI now runs as the `query-ui` Docker Compose service:

```bash
docker compose up query-ui
```

Then open:

```text
http://127.0.0.1:8765
```

The UI includes:

- a Splunk/Kibana-style saved-search sidebar
- a live SQL editor for read-only queries
- table, JSON, and chart views
- a schema browser
- 15 preloaded hospital analytics queries that you can edit and rerun

The saved-query catalog lives in:

```text
code/query_ui/saved_queries.py
```

For local development outside Docker, you can still run:

```bash
./run_query_ui.sh
```

The host script uses `docker compose exec` to query the `mariadb` service. The
containerized UI uses Docker networking and connects directly to host `mariadb`
on port `3306`.

## Reload Modes

The service supports a reload policy through the environment variable
`HOSPITAL_DB_RELOAD_MODE`.

It is already wired in `docker-compose.yml` like this:

```yaml
HOSPITAL_DB_RELOAD_MODE: ${HOSPITAL_DB_RELOAD_MODE:-preserve}
```

Available modes:

| Mode | Behavior |
|---|---|
| `preserve` | Default. Reuse the existing persisted database and skip reloads. |
| `checksum` | Reload only if the built SQL fingerprint changed since the last successful load. |
| `force` | Always rerun `install.sql` and `load.sql` even if a database volume already exists. |

### Default behavior

```bash
docker compose up
```

Equivalent to:

```bash
HOSPITAL_DB_RELOAD_MODE=preserve docker compose up
```

### Reload only when SQL changes

Useful after editing `sql/install.sql` or `sql/load.sql`:

```bash
HOSPITAL_DB_RELOAD_MODE=checksum docker compose up --build
```

The image stores a checksum of the SQL files at build time. After a successful
load, that checksum is saved in the data volume. On the next startup, the
container compares them and reloads only if they differ.

### Force a reload into the existing volume

```bash
HOSPITAL_DB_RELOAD_MODE=force docker compose up
```

This keeps the Docker volume itself, but the SQL scripts will drop and recreate
the `hospital` database contents.

## Connection Details

Use these values from a MySQL client or a future frontend/backend service:

```text
Host:     127.0.0.1
Port:     3307
User:     root
Password: root
Database: hospital
```

From another Compose service, use:

```text
Host:     mariadb
Port:     3306
User:     root
Password: root
Database: hospital
```

Or connect from the terminal:

```bash
docker exec -it hospital_db mariadb -uroot -proot hospital
```

## What the SQL Does

### `install.sql`

- drops and recreates the `hospital` database
- creates the schema, constraints, indexes, and triggers

### `load.sql`

- bulk-loads the reference CSV datasets into lookup tables
- creates and runs the stored procedure that inserts sample operational data

There is no separate `dummy_data.sql` file in the current setup. Sample data is
handled inside `load.sql`.

## How the Docker Setup Works

### MariaDB Dockerfile

The image uses a staged build:

1. an `alpine` stage copies `sql/` and `docs/*.csv` and computes a checksum
2. the final `mariadb:10.6` stage copies those baked assets into the image

This improves repeat builds and removes the need for runtime bind mounts for SQL
and CSV files.

### Query UI Dockerfile

`code/query_ui/Dockerfile` builds a small Python image with the MariaDB client
installed. The UI service exposes port `8765` and connects to the database using
these environment variables from `docker-compose.yml`:

- `HOSPITAL_DB_HOST=mariadb`
- `HOSPITAL_DB_PORT=3306`
- `HOSPITAL_DB_USER=root`
- `HOSPITAL_DB_PASSWORD=root`
- `HOSPITAL_DB_NAME=hospital`

### Entry point wrapper

`docker-entrypoint-wrapper.sh` sits in front of the standard MariaDB entrypoint.
It decides whether this is:

- a true first run with an empty volume
- a normal restart using persisted data
- a reload run based on `HOSPITAL_DB_RELOAD_MODE`

It also exports:

- `HOSPITAL_DB_FIRST_RUN=true` on first initialization
- `HOSPITAL_DB_FIRST_RUN=false` on subsequent starts

### Initialization script

`01_hospital_init.sh` executes:

1. `install.sql`
2. `load.sql`

After success, it writes the applied SQL fingerprint to:

```text
/var/lib/mysql/.hospital-db-sql.sha256
```

### Healthcheck

`hospital-db-healthcheck.sh` reports the container as healthy only when:

- MariaDB is accepting connections
- the `hospital` schema exists
- no initialization or reload is still in progress

## Important Notes

### SQL and CSV files are baked into the image

If you change:

- `sql/install.sql`
- `sql/load.sql`
- any of the CSV files in `docs/`

you should rebuild the image:

```bash
docker compose up --build
```

If you changed SQL and want the persisted database to be refreshed
automatically, use:

```bash
HOSPITAL_DB_RELOAD_MODE=checksum docker compose up --build
```

### `LOAD DATA INFILE`

`load.sql` uses `LOAD DATA INFILE`, so the container starts MariaDB with:

- `--local-infile=1`
- `--secure-file-priv=`
- `--character-set-server=utf8mb4`
- `--collation-server=utf8mb4_unicode_ci`
- `--max_allowed_packet=256M`

These flags are now defined in the image `CMD`, not in `docker-compose.yml`.

### No phpMyAdmin

This setup intentionally runs only MariaDB. Querying and visualization can be
handled by the local query console in `code/query_ui/`.

## Troubleshooting

**The database starts but old data is still there**

The default mode is `preserve`. Use one of:

```bash
HOSPITAL_DB_RELOAD_MODE=checksum docker compose up --build
```

or:

```bash
HOSPITAL_DB_RELOAD_MODE=force docker compose up
```

**The volume is in a bad state and reload still does not help**

Do a full reset:

```bash
docker compose down -v
docker compose up --build
```

**`LOAD DATA INFILE` fails**

Rebuild the image and start again:

```bash
docker compose up --build
```

**Port `3307` is already in use**

Change the port mapping in `code/docker-compose.yml`, for example:

```yaml
ports:
  - "3308:3306"
```

Then connect on port `3308`.
