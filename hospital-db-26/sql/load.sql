--ICD10 load
LOAD DATA INFILE '/tmp/icd10_data.csv'
INTO TABLE ICD10
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(icd_code, description, category);

--KEN
USE hospital;

LOAD DATA LOCAL INFILE 'hospital-db-26/docs/ken-codes-clean.csv'
INTO TABLE ken
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
       OPTIONALLY ENCLOSED BY '"'
LINES  TERMINATED BY '\n'
-- no IGNORE — clean CSV has no header row
(ken_code, description, base_cost, alos_days);