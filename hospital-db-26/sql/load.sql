USE hospital;

--ICD10 load
LOAD DATA INFILE '/tmp/docs/icd10_data.csv'
INTO TABLE ICD10
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(icd_code, description, category);

--PROCEDURE CATALOG
LOAD DATA INFILE '/tmp/docs/procedure_catalog.csv'
INTO TABLE procedure_catalog
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(procedure_code, name, category);

--LAB TEST CATALOG ignore cause some duplicates to ignore
LOAD DATA INFILE '/tmp/docs/lab_test_catalog.csv'
IGNORE INTO TABLE lab_test_catalog 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(test_code, test_type, name);

--KEN
LOAD DATA INFILE '/tmp/docs/ken-codes-clean.csv'
INTO TABLE ken
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(ken_code, description, base_cost, alos_days);
