-- KEN codes — load via LOAD DATA INFILE
-- Uses a staging table because:
--   1. Cost column contains "€" symbols that need stripping
--   2. Category header rows (no cost/alos) must be filtered out
--   3. One split row (Ε03Α) cannot be recovered — it will be skipped
--
-- Run with:
--   mysql --local-infile=1 -u root -p hospital < load_ken_infile.sql
-- Or if the CSV is on the MySQL server host, remove LOCAL below.

USE hospital;

-- ── 1. Staging table (all nullable, raw strings) ──────────────────────────
CREATE TEMPORARY TABLE ken_stage (
    ken_code    VARCHAR(20),
    description TEXT,
    cost_raw    VARCHAR(50),
    alos_raw    VARCHAR(10)
);

-- ── 2. Load CSV into staging ───────────────────────────────────────────────
-- IGNORE 16 LINES skips 15 junk rows + 1 header row.
-- Adjust the file path to the absolute path on your machine.
LOAD DATA LOCAL INFILE 'hospital-db-26/docs/ken-codes-csv.csv'
INTO TABLE ken_stage
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
LINES  TERMINATED BY '\n'
IGNORE 16 LINES
(ken_code, description, cost_raw, alos_raw);

-- ── 3. Transfer into ken, cleaning cost and filtering bad rows ─────────────
INSERT INTO ken (ken_code, description, base_cost, alos_days)
SELECT
    TRIM(ken_code),
    TRIM(description),
    CAST(
        TRIM(REPLACE(REPLACE(REPLACE(cost_raw, '€', ''), '\u20ac', ''), ' ', ''))
        AS DECIMAL(10,2)
    ),
    CAST(TRIM(alos_raw) AS UNSIGNED)
FROM ken_stage
WHERE
    -- skip blank/category-header rows
    TRIM(ken_code)   != ''
    AND TRIM(alos_raw)  != ''
    -- cost must be a valid number after stripping the euro sign
    AND TRIM(REPLACE(REPLACE(cost_raw, '€', ''), ' ', ''))
        REGEXP '^[0-9]+(\\.[0-9]+)?$';

DROP TEMPORARY TABLE ken_stage;
