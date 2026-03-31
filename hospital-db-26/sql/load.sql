-- =====================================================
-- load.sql  —  Load KEN codes from CSV
-- Γενικό Νοσοκομείο «Υγειόπολης»
-- =====================================================
--
-- Source CSV : hospital-db-26/docs/ken-codes-clean.csv
--   (exported from ken-codes-UPDATED.xlsx — no header row,
--    no euro signs, category-header rows removed)
--
-- How to run (file on client machine):
--   mysql --local-infile=1 -u root -p hospital < hospital-db-26/sql/load.sql

-- If the CSV is already on the MySQL server host,
-- remove LOCAL and use the absolute server-side path.
-- =====================================================

USE hospital;

LOAD DATA LOCAL INFILE 'hospital-db-26/docs/ken-codes-clean.csv'
INTO TABLE ken
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
       OPTIONALLY ENCLOSED BY '"'
LINES  TERMINATED BY '\n'
-- no IGNORE — clean CSV has no header row
(ken_code, description, base_cost, alos_days);
