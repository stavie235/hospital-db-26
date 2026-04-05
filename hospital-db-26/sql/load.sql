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

--DRUGS
LOAD DATA INFILE '/tmp/docs/drug_data-2.csv'
INTO TABLE drug
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(drug_name, description);

--ACTIVE SUBSTANCES
LOAD DATA INFILE '/tmp/docs/substance_data-2.csv'
INTO TABLE active_substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(substance_name);

--DRUG <-> SUBSTANCE (M:N) -- load via temp table because CSV uses names not IDs
CREATE TEMPORARY TABLE tmp_drug_substance (
    drug_name     VARCHAR(500),
    substance_name VARCHAR(500)
);

LOAD DATA INFILE '/tmp/docs/drug_substance_data-2.csv'
INTO TABLE tmp_drug_substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(drug_name, substance_name);

INSERT IGNORE INTO drug_substance (drug_id, substance_id)
SELECT d.drug_id, s.substance_id
FROM tmp_drug_substance t
JOIN drug d ON d.drug_name = t.drug_name
JOIN active_substance s ON s.substance_name = t.substance_name;

DROP TEMPORARY TABLE tmp_drug_substance;
