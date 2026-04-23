USE hospital;

-- =====================================================
-- dummy_data.sql
-- Populate the operational tables with deterministic
-- dummy data after:
--   1) sql/install2.sql
--   2) sql/load.sql
--
-- The script is idempotent for the operational tables:
-- it deletes previously generated hospital data and keeps
-- the reference datasets (ICD10, KEN, catalogs, drugs).
-- =====================================================

DROP PROCEDURE IF EXISTS generate_dummy_data;

DELIMITER //

CREATE PROCEDURE generate_dummy_data()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE k INT DEFAULT 0;

    DECLARE v_shift_id INT;
    DECLARE v_doctor_id INT;
    DECLARE v_nurse_id INT;
    DECLARE v_admin_id INT;

    DECLARE v_department_id INT;
    DECLARE v_bed_id INT;
    DECLARE v_patient_id INT;
    DECLARE v_hospitalization_id INT;

    DECLARE v_admission_date DATE;
    DECLARE v_discharge_date DATE;
    DECLARE v_length_days INT;

    DECLARE v_ken_rn INT;
    DECLARE v_icd_rn INT;
    DECLARE v_drug_rn INT;
    DECLARE v_substance_rn INT;
    DECLARE v_lab_rn INT;
    DECLARE v_proc_rn INT;

    DECLARE v_ken_code VARCHAR(20);
    DECLARE v_icd_code VARCHAR(10);
    DECLARE v_drug_id INT;
    DECLARE v_substance_id INT;
    DECLARE v_test_code VARCHAR(20);
    DECLARE v_proc_code VARCHAR(20);

    DECLARE v_ken_count INT;
    DECLARE v_icd_count INT;
    DECLARE v_drug_count INT;
    DECLARE v_substance_count INT;
    DECLARE v_lab_count INT;
    DECLARE v_proc_count INT;

    DECLARE v_tmp_patient_id INT;
    DECLARE v_tmp_admission DATE;
    DECLARE v_tmp_discharge DATE;

    -- -------------------------------------------------
    -- 0. Clean operational tables only
    -- -------------------------------------------------
    DELETE FROM procedure_assistant;
    DELETE FROM medical_procedure;
    DELETE FROM lab_test;
    DELETE FROM doctor_evaluation;
    DELETE FROM evaluation;
    DELETE FROM triage_record;
    DELETE FROM prescription;
    DELETE FROM patient_allergy;
    DELETE FROM hospitalization;
    DELETE FROM emergency_contact;
    DELETE FROM shift_assignment;
    DELETE FROM shift;
    DELETE FROM bed;
    DELETE FROM doctor_department;
    DELETE FROM administrative;
    DELETE FROM nurse;
    DELETE FROM department;
    DELETE FROM procedure_room;
    DELETE FROM doctor;
    DELETE FROM patient;
    DELETE FROM staff;

    ALTER TABLE staff AUTO_INCREMENT = 1;
    ALTER TABLE department AUTO_INCREMENT = 1;
    ALTER TABLE bed AUTO_INCREMENT = 1;
    ALTER TABLE shift AUTO_INCREMENT = 1;
    ALTER TABLE procedure_room AUTO_INCREMENT = 1;
    ALTER TABLE patient AUTO_INCREMENT = 1;
    ALTER TABLE emergency_contact AUTO_INCREMENT = 1;
    ALTER TABLE hospitalization AUTO_INCREMENT = 1;
    ALTER TABLE triage_record AUTO_INCREMENT = 1;
    ALTER TABLE evaluation AUTO_INCREMENT = 1;
    ALTER TABLE doctor_evaluation AUTO_INCREMENT = 1;
    ALTER TABLE lab_test AUTO_INCREMENT = 1;
    ALTER TABLE medical_procedure AUTO_INCREMENT = 1;
    ALTER TABLE prescription AUTO_INCREMENT = 1;

    -- -------------------------------------------------
    -- 1. Temporary lookup maps for deterministic access
    -- -------------------------------------------------
    DROP TEMPORARY TABLE IF EXISTS tmp_ken_map;
    DROP TEMPORARY TABLE IF EXISTS tmp_icd_map;
    DROP TEMPORARY TABLE IF EXISTS tmp_drug_map;
    DROP TEMPORARY TABLE IF EXISTS tmp_substance_map;
    DROP TEMPORARY TABLE IF EXISTS tmp_lab_map;
    DROP TEMPORARY TABLE IF EXISTS tmp_proc_map;

    CREATE TEMPORARY TABLE tmp_ken_map AS
    SELECT ROW_NUMBER() OVER (ORDER BY ken_code) AS rn, ken_code
    FROM ken;

    CREATE TEMPORARY TABLE tmp_icd_map AS
    SELECT ROW_NUMBER() OVER (ORDER BY icd_code) AS rn, icd_code
    FROM ICD10;

    CREATE TEMPORARY TABLE tmp_drug_map AS
    SELECT ROW_NUMBER() OVER (ORDER BY drug_id) AS rn, drug_id
    FROM drug;

    CREATE TEMPORARY TABLE tmp_substance_map AS
    SELECT ROW_NUMBER() OVER (ORDER BY substance_id) AS rn, substance_id
    FROM active_substance;

    CREATE TEMPORARY TABLE tmp_lab_map AS
    SELECT ROW_NUMBER() OVER (ORDER BY test_code) AS rn, test_code
    FROM lab_test_catalog;

    CREATE TEMPORARY TABLE tmp_proc_map AS
    SELECT ROW_NUMBER() OVER (ORDER BY procedure_code) AS rn, procedure_code
    FROM procedure_catalog
    WHERE category = 'χειρουργική';

    SELECT COUNT(*) INTO v_ken_count FROM tmp_ken_map;
    SELECT COUNT(*) INTO v_icd_count FROM tmp_icd_map;
    SELECT COUNT(*) INTO v_drug_count FROM tmp_drug_map;
    SELECT COUNT(*) INTO v_substance_count FROM tmp_substance_map;
    SELECT COUNT(*) INTO v_lab_count FROM tmp_lab_map;
    SELECT COUNT(*) INTO v_proc_count FROM tmp_proc_map;

    IF v_proc_count = 0 THEN
        DROP TEMPORARY TABLE tmp_proc_map;
        CREATE TEMPORARY TABLE tmp_proc_map AS
        SELECT ROW_NUMBER() OVER (ORDER BY procedure_code) AS rn, procedure_code
        FROM procedure_catalog;
        SELECT COUNT(*) INTO v_proc_count FROM tmp_proc_map;
    END IF;

    IF v_ken_count = 0 OR v_icd_count = 0 OR v_drug_count = 0 OR
       v_substance_count = 0 OR v_lab_count = 0 OR v_proc_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reference datasets are missing. Run sql/load.sql first.';
    END IF;

    -- -------------------------------------------------
    -- 2. Departments
    -- -------------------------------------------------
    INSERT INTO department (name, description, num_beds, floor_building, director_id, photo_url)
    VALUES
        ('Καρδιολογική', 'Κλινική καρδιολογίας και στεφανιαίας φροντίδας.', 20, 'A-1', NULL, 'https://example.com/departments/cardiology.jpg'),
        ('Χειρουργική', 'Γενική χειρουργική κλινική.', 20, 'A-2', NULL, 'https://example.com/departments/surgery.jpg'),
        ('ΜΕΘ', 'Μονάδα εντατικής θεραπείας.', 20, 'A-3', NULL, 'https://example.com/departments/icu.jpg'),
        ('Επείγοντα', 'Τμήμα επειγόντων περιστατικών.', 20, 'A-0', NULL, 'https://example.com/departments/er.jpg'),
        ('Ορθοπαιδική', 'Ορθοπαιδική κλινική.', 20, 'B-1', NULL, 'https://example.com/departments/ortho.jpg'),
        ('Νευρολογική', 'Νευρολογική κλινική.', 20, 'B-2', NULL, 'https://example.com/departments/neuro.jpg'),
        ('Ογκολογική', 'Ογκολογικό τμήμα.', 20, 'B-3', NULL, 'https://example.com/departments/oncology.jpg'),
        ('Πνευμονολογική', 'Πνευμονολογική κλινική.', 20, 'C-1', NULL, 'https://example.com/departments/pulmo.jpg'),
        ('Νεφρολογική', 'Νεφρολογικό τμήμα.', 20, 'C-2', NULL, 'https://example.com/departments/nephro.jpg'),
        ('Γαστρεντερολογική', 'Γαστρεντερολογική κλινική.', 20, 'C-3', NULL, 'https://example.com/departments/gastro.jpg'),
        ('Παιδιατρική', 'Παιδιατρικό τμήμα.', 20, 'D-1', NULL, 'https://example.com/departments/pediatrics.jpg'),
        ('Δερματολογική', 'Δερματολογική κλινική.', 20, 'D-2', NULL, 'https://example.com/departments/derma.jpg'),
        ('ΩΡΛ', 'Ωτορινολαρυγγολογικό τμήμα.', 20, 'D-3', NULL, 'https://example.com/departments/ent.jpg'),
        ('Οφθαλμολογική', 'Οφθαλμολογικό τμήμα.', 20, 'E-1', NULL, 'https://example.com/departments/ophthalmology.jpg'),
        ('Αιματολογική', 'Αιματολογική κλινική.', 20, 'E-2', NULL, 'https://example.com/departments/hematology.jpg');

    -- -------------------------------------------------
    -- 3. Doctors (80)
    --    IDs 1..80 in staff / doctor after reset
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 80 DO
        INSERT INTO staff (
            amka, first_name, last_name, age, email, phone,
            hiring_date, staff_type, photo_url, description
        )
        VALUES (
            LPAD(10000000000 + i, 11, '0'),
            CONCAT('Doctor', i),
            CONCAT('Surname', i),
            31 + MOD(i, 24),
            CONCAT('doctor', i, '@hospital.local'),
            CONCAT('210', LPAD(i, 7, '0')),
            DATE_ADD('2010-01-01', INTERVAL i * 23 DAY),
            'doctor',
            CONCAT('https://example.com/staff/doctors/', i, '.jpg'),
            CONCAT('Dummy profile for doctor ', i)
        );

        INSERT INTO doctor (
            staff_id, license_number, specialty, `rank`, supervisor_id
        )
        VALUES (
            i,
            CONCAT('LIC-', LPAD(i, 5, '0')),
            CASE MOD(i, 10)
                WHEN 0 THEN 'Καρδιολογία'
                WHEN 1 THEN 'Χειρουργική'
                WHEN 2 THEN 'Αναισθησιολογία'
                WHEN 3 THEN 'Ορθοπαιδική'
                WHEN 4 THEN 'Νευρολογία'
                WHEN 5 THEN 'Πνευμονολογία'
                WHEN 6 THEN 'Νεφρολογία'
                WHEN 7 THEN 'Γαστρεντερολογία'
                WHEN 8 THEN 'Αιματολογία'
                ELSE 'Παθολογία'
            END,
            CASE
                WHEN i <= 15 THEN 'Διευθυντής'
                WHEN i <= 35 THEN 'Επιμελητής Α'
                WHEN i <= 55 THEN 'Επιμελητής Β'
                ELSE 'Ειδικευόμενος'
            END,
            CASE
                WHEN i <= 15 THEN NULL
                WHEN i <= 35 THEN 1 + MOD(i - 16, 15)
                WHEN i <= 55 THEN 16 + MOD(i - 36, 20)
                ELSE 16 + MOD(i - 56, 20)
            END
        );

        SET i = i + 1;
    END WHILE;

    UPDATE department
    SET director_id = department_id
    WHERE department_id BETWEEN 1 AND 15;

    SET i = 1;
    WHILE i <= 80 DO
        INSERT INTO doctor_department (staff_id, department_id)
        VALUES (i, 1 + MOD(i - 1, 15));

        IF MOD(i, 3) = 0 THEN
            INSERT INTO doctor_department (staff_id, department_id)
            VALUES (i, 1 + MOD(i + 4, 15));
        END IF;

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 4. Nurses (120) and administrative staff (60)
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 120 DO
        INSERT INTO staff (
            amka, first_name, last_name, age, email, phone,
            hiring_date, staff_type, photo_url, description
        )
        VALUES (
            LPAD(20000000000 + i, 11, '0'),
            CONCAT('Nurse', i),
            CONCAT('Surname', i),
            24 + MOD(i, 26),
            CONCAT('nurse', i, '@hospital.local'),
            CONCAT('211', LPAD(i, 7, '0')),
            DATE_ADD('2012-01-01', INTERVAL i * 11 DAY),
            'nurse',
            CONCAT('https://example.com/staff/nurses/', i, '.jpg'),
            CONCAT('Dummy profile for nurse ', i)
        );

        INSERT INTO nurse (staff_id, `rank`, department_id)
        VALUES (
            80 + i,
            CASE MOD(i, 3)
                WHEN 0 THEN 'Προϊστάμενος'
                WHEN 1 THEN 'Νοσηλευτής'
                ELSE 'Βοηθός Νοσηλευτή'
            END,
            1 + MOD(i - 1, 15)
        );

        SET i = i + 1;
    END WHILE;

    SET i = 1;
    WHILE i <= 60 DO
        INSERT INTO staff (
            amka, first_name, last_name, age, email, phone,
            hiring_date, staff_type, photo_url, description
        )
        VALUES (
            LPAD(30000000000 + i, 11, '0'),
            CONCAT('Admin', i),
            CONCAT('Surname', i),
            26 + MOD(i, 28),
            CONCAT('admin', i, '@hospital.local'),
            CONCAT('212', LPAD(i, 7, '0')),
            DATE_ADD('2011-05-01', INTERVAL i * 13 DAY),
            'administrative',
            CONCAT('https://example.com/staff/admin/', i, '.jpg'),
            CONCAT('Dummy profile for admin staff ', i)
        );

        INSERT INTO administrative (staff_id, role, office_name, department_id)
        VALUES (
            200 + i,
            CASE MOD(i, 5)
                WHEN 0 THEN 'Γραμματέας'
                WHEN 1 THEN 'Λογιστής'
                WHEN 2 THEN 'Υποδοχή'
                WHEN 3 THEN 'Μητρώο Ασθενών'
                ELSE 'Προμήθειες'
            END,
            CONCAT('Office-', 1 + MOD(i - 1, 15)),
            1 + MOD(i - 1, 15)
        );

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 5. Beds and procedure rooms
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 15 DO
        SET j = 1;
        WHILE j <= 20 DO
            INSERT INTO bed (`number`, `type`, `status`, department_id)
            VALUES (
                j,
                CASE MOD(j, 4)
                    WHEN 0 THEN 'ΜΕΘ'
                    WHEN 1 THEN 'μονόκλινο'
                    WHEN 2 THEN 'δίκλινο'
                    ELSE 'πολύκλινο'
                END,
                CASE
                    WHEN j = 20 THEN 'υπό συντήρηση'
                    ELSE 'διαθέσιμη'
                END,
                i
            );
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;

    INSERT INTO procedure_room (room_name, room_type, description, photo_url)
    VALUES
        ('Χειρουργείο 1', 'χειρουργείο', 'Κύριο χειρουργείο γενικής χειρουργικής.', 'https://example.com/rooms/or1.jpg'),
        ('Χειρουργείο 2', 'χειρουργείο', 'Χειρουργείο ορθοπαιδικών πράξεων.', 'https://example.com/rooms/or2.jpg'),
        ('Χειρουργείο 3', 'χειρουργείο', 'Χειρουργείο καρδιοχειρουργικών πράξεων.', 'https://example.com/rooms/or3.jpg'),
        ('Χειρουργείο 4', 'χειρουργείο', 'Χειρουργείο μικρών επεμβάσεων.', 'https://example.com/rooms/or4.jpg'),
        ('Χειρουργείο 5', 'χειρουργείο', 'Χειρουργείο επειγόντων περιστατικών.', 'https://example.com/rooms/or5.jpg'),
        ('Αίθουσα Επέμβασης 1', 'αίθουσα επέμβασης', 'Αίθουσα επεμβατικών εξετάσεων.', 'https://example.com/rooms/pr1.jpg'),
        ('Αίθουσα Επέμβασης 2', 'αίθουσα επέμβασης', 'Αίθουσα ενδοσκοπικών πράξεων.', 'https://example.com/rooms/pr2.jpg'),
        ('Αίθουσα Επέμβασης 3', 'αίθουσα επέμβασης', 'Αίθουσα βιοψιών και μικρών πράξεων.', 'https://example.com/rooms/pr3.jpg'),
        ('Αίθουσα Επέμβασης 4', 'αίθουσα επέμβασης', 'Αίθουσα διαγνωστικών παρεμβάσεων.', 'https://example.com/rooms/pr4.jpg'),
        ('Αίθουσα Επέμβασης 5', 'αίθουσα επέμβασης', 'Αίθουσα αγγειογραφιών.', 'https://example.com/rooms/pr5.jpg');

    -- -------------------------------------------------
    -- 6. Patients (200) and emergency contacts
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 200 DO
        INSERT INTO patient (
            amka, first_name, last_name, father_name, age, gender, weight,
            height, address, phone, email, profession, nationality,
            insurance_provider, photo_url
        )
        VALUES (
            LPAD(40000000000 + i, 11, '0'),
            CONCAT('Patient', i),
            CONCAT('Surname', i),
            CONCAT('Father', 1 + MOD(i, 40)),
            18 + MOD(i, 70),
            CASE WHEN MOD(i, 2) = 0 THEN 'F' ELSE 'M' END,
            52 + MOD(i, 45),
            155 + MOD(i, 35),
            CONCAT('Dummy Street ', i, ', Athens'),
            CONCAT('213', LPAD(i, 7, '0')),
            CONCAT('patient', i, '@mail.local'),
            CASE MOD(i, 6)
                WHEN 0 THEN 'Εκπαιδευτικός'
                WHEN 1 THEN 'Μηχανικός'
                WHEN 2 THEN 'Συνταξιούχος'
                WHEN 3 THEN 'Ιδιωτικός Υπάλληλος'
                WHEN 4 THEN 'Φοιτητής'
                ELSE 'Ελεύθερος Επαγγελματίας'
            END,
            CASE MOD(i, 5)
                WHEN 0 THEN 'Ελλάδα'
                WHEN 1 THEN 'Κύπρος'
                WHEN 2 THEN 'Ιταλία'
                WHEN 3 THEN 'Γερμανία'
                ELSE 'Βουλγαρία'
            END,
            CASE MOD(i, 4)
                WHEN 0 THEN 'ΕΦΚΑ'
                WHEN 1 THEN 'Ιδιωτική Ασφάλεια'
                WHEN 2 THEN 'Ανασφάλιστος'
                ELSE 'Στρατιωτική Ασφάλιση'
            END,
            CONCAT('https://example.com/patients/', i, '.jpg')
        );

        INSERT INTO emergency_contact (patient_id, full_name, phone, relationship)
        VALUES (
            i,
            CONCAT('Contact ', i),
            CONCAT('694', LPAD(i, 7, '0')),
            CASE MOD(i, 4)
                WHEN 0 THEN 'Σύζυγος'
                WHEN 1 THEN 'Γονέας'
                WHEN 2 THEN 'Αδελφός'
                ELSE 'Τέκνο'
            END
        );

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 7. Shift schedule for 5 departments over one week
    --    The current schema does not enforce the minimum
    --    staffing rule; this script still generates valid
    --    shift assignments for a realistic subset.
    -- -------------------------------------------------
    SET i = 0;
    WHILE i < 7 DO
        SET j = 1;
        WHILE j <= 5 DO
            INSERT INTO shift (department_id, shift_date, shift_type)
            VALUES (j, DATE_ADD('2026-04-06', INTERVAL i DAY), 'morning');
            SET v_shift_id = LAST_INSERT_ID();

            SET k = 0;
            WHILE k < 3 DO
                SET v_doctor_id = 1 + (j - 1) * 3 + k;
                INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_doctor_id);
                SET k = k + 1;
            END WHILE;

            SET k = 0;
            WHILE k < 6 DO
                SET v_nurse_id = 81 + (j - 1) * 6 + k;
                INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_nurse_id);
                SET k = k + 1;
            END WHILE;

            SET k = 0;
            WHILE k < 2 DO
                SET v_admin_id = 201 + (j - 1) * 2 + k;
                INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_admin_id);
                SET k = k + 1;
            END WHILE;

            INSERT INTO shift (department_id, shift_date, shift_type)
            VALUES (j, DATE_ADD('2026-04-06', INTERVAL i DAY), 'afternoon');
            SET v_shift_id = LAST_INSERT_ID();

            SET k = 0;
            WHILE k < 3 DO
                SET v_doctor_id = 16 + (j - 1) * 3 + k;
                INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_doctor_id);
                SET k = k + 1;
            END WHILE;

            SET k = 0;
            WHILE k < 6 DO
                SET v_nurse_id = 111 + (j - 1) * 6 + k;
                INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_nurse_id);
                SET k = k + 1;
            END WHILE;

            SET k = 0;
            WHILE k < 2 DO
                SET v_admin_id = 211 + (j - 1) * 2 + k;
                INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_admin_id);
                SET k = k + 1;
            END WHILE;

            -- Night shifts: μόνο 3 τμήματα (j<=3) για να αποφύγουμε:
            -- (α) >3 συνεχόμενες νύχτες (Night A: 31-39, Night B: 46-54 — μηδενικό overlap)
            -- (β) Ειδικευόμενους (56-80) χωρίς senior στη βάρδια
            IF j <= 3 THEN
                INSERT INTO shift (department_id, shift_date, shift_type)
                VALUES (j, DATE_ADD('2026-04-06', INTERVAL i DAY), 'night');
                SET v_shift_id = LAST_INSERT_ID();

                SET k = 0;
                WHILE k < 3 DO
                    IF i < 3 OR i = 6 THEN
                        SET v_doctor_id = 31 + (j - 1) * 3 + k;
                    ELSE
                        SET v_doctor_id = 46 + (j - 1) * 3 + k;
                    END IF;
                    INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_doctor_id);
                    SET k = k + 1;
                END WHILE;

                SET k = 0;
                WHILE k < 6 DO
                    IF i < 3 OR i = 6 THEN
                        SET v_nurse_id = 141 + (j - 1) * 6 + k;
                    ELSE
                        SET v_nurse_id = 171 + (j - 1) * 6 + k;
                    END IF;
                    INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_nurse_id);
                    SET k = k + 1;
                END WHILE;

                SET k = 0;
                WHILE k < 2 DO
                    IF i < 3 OR i = 6 THEN
                        SET v_admin_id = 221 + (j - 1) * 2 + k;
                    ELSE
                        SET v_admin_id = 231 + (j - 1) * 2 + k;
                    END IF;
                    INSERT INTO shift_assignment (shift_id, staff_id) VALUES (v_shift_id, v_admin_id);
                    SET k = k + 1;
                END WHILE;
            END IF;

            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 8. Hospitalizations (500 total, 470 discharged + 30 active)
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 470 DO
        SET v_department_id = 1 + MOD(i - 1, 15);
        SET v_patient_id = 1 + MOD(i - 1, 200);
        SET v_bed_id = (v_department_id - 1) * 20 + 1 + MOD(FLOOR((i - 1) / 15), 18);
        SET v_admission_date = DATE_ADD('2023-01-01', INTERVAL i * 3 DAY);
        SET v_length_days = 2 + MOD(i, 9);

        SET v_ken_rn = 1 + MOD(i - 1, v_ken_count);
        SET v_icd_rn = 1 + MOD(i * 7 - 1, v_icd_count);

        SELECT ken_code INTO v_ken_code FROM tmp_ken_map WHERE rn = v_ken_rn;
        SELECT icd_code INTO v_icd_code FROM tmp_icd_map WHERE rn = v_icd_rn;

        INSERT INTO hospitalization (
            patient_id, bed_id, department_id, ken_code, admission_date,
            discharge_date, admission_diagnosis, icd10_code, discharge_desc, total_cost
        )
        VALUES (
            v_patient_id,
            v_bed_id,
            v_department_id,
            v_ken_code,
            v_admission_date,
            NULL,
            CONCAT('Εισαγωγή λόγω περιστατικού #', i),
            v_icd_code,
            NULL,
            NULL
        );

        SET v_hospitalization_id = LAST_INSERT_ID();
        SET v_discharge_date = DATE_ADD(v_admission_date, INTERVAL v_length_days DAY);

        UPDATE hospitalization
        SET discharge_date = v_discharge_date,
            discharge_desc = CONCAT('Εξιτήριο νοσηλείας #', v_hospitalization_id)
        WHERE hospitalization_id = v_hospitalization_id;

        SET i = i + 1;
    END WHILE;

    SET i = 1;
    WHILE i <= 30 DO
        SET v_department_id = 1 + MOD(i - 1, 15);
        SET v_patient_id = 171 + MOD(i - 1, 30);
        SET v_bed_id = (v_department_id - 1) * 20 + 19 + MOD(i - 1, 2);
        SET v_admission_date = DATE_ADD('2026-03-15', INTERVAL i DAY);

        SET v_ken_rn = 1 + MOD(i * 5 - 1, v_ken_count);
        SET v_icd_rn = 1 + MOD(i * 11 - 1, v_icd_count);

        SELECT ken_code INTO v_ken_code FROM tmp_ken_map WHERE rn = v_ken_rn;
        SELECT icd_code INTO v_icd_code FROM tmp_icd_map WHERE rn = v_icd_rn;

        INSERT INTO hospitalization (
            patient_id, bed_id, department_id, ken_code, admission_date,
            discharge_date, admission_diagnosis, icd10_code, discharge_desc, total_cost
        )
        VALUES (
            v_patient_id,
            v_bed_id,
            v_department_id,
            v_ken_code,
            v_admission_date,
            NULL,
            CONCAT('Ενεργή νοσηλεία #', i),
            v_icd_code,
            NULL,
            NULL
        );

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 9. Triage records
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 220 DO
        INSERT INTO triage_record (
            patient_id, nurse_id, hospitalization_id, arrival_time,
            symptoms, urgency_level, outcome, outcome_time
        )
        VALUES (
            1 + MOD(i - 1, 200),
            81 + MOD(i - 1, 15),
            i,
            DATE_ADD(CONCAT((SELECT admission_date FROM hospitalization WHERE hospitalization_id = i), ' 06:00:00'), INTERVAL MOD(i, 120) MINUTE),
            CONCAT('Συμπτώματα περιστατικού ', i),
            1 + MOD(i - 1, 5),
            'νοσηλεία',
            DATE_ADD(CONCAT((SELECT admission_date FROM hospitalization WHERE hospitalization_id = i), ' 07:30:00'), INTERVAL MOD(i, 60) MINUTE)
        );
        SET i = i + 1;
    END WHILE;

    SET i = 1;
    WHILE i <= 60 DO
        INSERT INTO triage_record (
            patient_id, nurse_id, hospitalization_id, arrival_time,
            symptoms, urgency_level, outcome, outcome_time
        )
        VALUES (
            i,
            96 + MOD(i - 1, 10),
            NULL,
            DATE_ADD('2026-04-01 08:00:00', INTERVAL i * 3 HOUR),
            CONCAT('Μη νοσηλευθέν περιστατικό ', i),
            2 + MOD(i - 1, 4),
            'αποχώρηση',
            DATE_ADD('2026-04-01 08:30:00', INTERVAL i * 3 HOUR)
        );
        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 10. Prescriptions (300)
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 300 DO
        SET v_hospitalization_id = 1 + MOD(i - 1, 300);

        SELECT patient_id, admission_date, COALESCE(discharge_date, DATE_ADD(admission_date, INTERVAL 5 DAY))
        INTO v_tmp_patient_id, v_tmp_admission, v_tmp_discharge
        FROM hospitalization
        WHERE hospitalization_id = v_hospitalization_id;

        SET v_drug_rn = 1 + MOD(i * 13 - 1, v_drug_count);
        SELECT drug_id INTO v_drug_id FROM tmp_drug_map WHERE rn = v_drug_rn;

        INSERT INTO prescription (
            hospitalization_id, doctor_id, patient_id, drug_id,
            dosage, frequency, start_date, end_date
        )
        VALUES (
            v_hospitalization_id,
            1 + MOD(i - 1, 80),
            v_tmp_patient_id,
            v_drug_id,
            CONCAT(1 + MOD(i, 3), ' δισκίο'),
            CASE MOD(i, 4)
                WHEN 0 THEN '1x ημερησίως'
                WHEN 1 THEN '2x ημερησίως'
                WHEN 2 THEN 'κάθε 8 ώρες'
                ELSE 'κάθε 12 ώρες'
            END,
            DATE_ADD(v_tmp_admission, INTERVAL MOD(i, 2) DAY),
            LEAST(
                DATE_ADD(v_tmp_admission, INTERVAL 3 + MOD(i, 4) DAY),
                v_tmp_discharge
            )
        );

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 11. Patient allergies (after prescriptions to avoid
    --     the prescription trigger blocking the generator)
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 120 DO
        SET v_substance_rn = 1 + MOD(i * 17 - 1, v_substance_count);
        SELECT substance_id INTO v_substance_id FROM tmp_substance_map WHERE rn = v_substance_rn;

        INSERT IGNORE INTO patient_allergy (patient_id, substance_id)
        VALUES (1 + MOD(i - 1, 60), v_substance_id);

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 12. Evaluations (320 discharged hospitalizations)
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 320 DO
        INSERT INTO evaluation (
            hospitalization_id, nursing_care,
            cleanliness, food, overall, comments, evaluation_date
        )
        VALUES (
            i,
            3 + MOD(i + 1, 3),
            3 + MOD(i + 2, 3),
            2 + MOD(i, 4),
            3 + MOD(i, 3),
            CONCAT('Σχόλιο αξιολόγησης για νοσηλεία ', i),
            DATE_ADD((SELECT discharge_date FROM hospitalization WHERE hospitalization_id = i), INTERVAL 3 DAY)
        );

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 12b. Doctor evaluations (~250, based on prescriptions)
    --      Ο ιατρός πρέπει να έχει συνταγογραφήσει στη νοσηλεία
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 250 DO
        SET v_hospitalization_id = 1 + MOD(i - 1, 300);

        INSERT IGNORE INTO doctor_evaluation (
            hospitalization_id, doctor_id, medical_care, evaluation_date
        )
        VALUES (
            v_hospitalization_id,
            1 + MOD(i - 1, 80),
            3 + MOD(i, 3),
            DATE_ADD((SELECT discharge_date FROM hospitalization WHERE hospitalization_id = v_hospitalization_id), INTERVAL 4 DAY)
        );

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 13. Lab tests (200)
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 200 DO
        SET v_hospitalization_id = 1 + MOD(i - 1, 220);
        SET v_lab_rn = 1 + MOD(i * 19 - 1, v_lab_count);
        SELECT test_code INTO v_test_code FROM tmp_lab_map WHERE rn = v_lab_rn;

        SELECT admission_date, COALESCE(discharge_date, DATE_ADD(admission_date, INTERVAL 5 DAY))
        INTO v_tmp_admission, v_tmp_discharge
        FROM hospitalization
        WHERE hospitalization_id = v_hospitalization_id;

        INSERT INTO lab_test (
            hospitalization_id, ordered_by, test_code, test_date,
            result_text, result_numeric, measurement_unit, cost
        )
        VALUES (
            v_hospitalization_id,
            1 + MOD(i - 1, 80),
            v_test_code,
            LEAST(DATE_ADD(v_tmp_admission, INTERVAL 1 + MOD(i, 3) DAY), v_tmp_discharge),
            CONCAT('Αποτέλεσμα εξέτασης ', i),
            ROUND(10 + MOD(i * 7, 250) / 10, 2),
            CASE MOD(i, 4)
                WHEN 0 THEN 'mg/dL'
                WHEN 1 THEN 'U/L'
                WHEN 2 THEN 'mmol/L'
                ELSE 'g/dL'
            END,
            25 + MOD(i, 90)
        );

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 14. Medical procedures (150) + assistants
    -- -------------------------------------------------
    SET i = 1;
    WHILE i <= 150 DO
        SET v_hospitalization_id = 1 + MOD(i - 1, 180);
        SET v_proc_rn = 1 + MOD(i * 23 - 1, v_proc_count);
        SELECT procedure_code INTO v_proc_code FROM tmp_proc_map WHERE rn = v_proc_rn;

        INSERT INTO medical_procedure (
            procedure_code, hospitalization_id, room_id, primary_surgeon_id,
            start_time, end_time, actual_cost
        )
        VALUES (
            v_proc_code,
            v_hospitalization_id,
            1 + MOD(i - 1, 10),
            1 + MOD(i - 1, 30),
            DATE_ADD(
                DATE_ADD('2026-01-05 08:00:00', INTERVAL FLOOR((i - 1) / 30) DAY),
                INTERVAL (MOD(FLOOR((i - 1) / 10), 3) * 4) HOUR
            ),
            DATE_ADD(
                DATE_ADD('2026-01-05 10:00:00', INTERVAL FLOOR((i - 1) / 30) DAY),
                INTERVAL (MOD(FLOOR((i - 1) / 10), 3) * 4) HOUR
            ),
            1200 + MOD(i * 37, 4800)
        );

        SET v_hospitalization_id = LAST_INSERT_ID();

        INSERT INTO procedure_assistant (procedure_id, staff_id, role)
        VALUES
            (v_hospitalization_id, 81 + MOD(i - 1, 30), 'scrub nurse'),
            (v_hospitalization_id, 111 + MOD(i - 1, 30), 'assistant nurse');

        SET i = i + 1;
    END WHILE;

    -- -------------------------------------------------
    -- 15. Final summary
    -- -------------------------------------------------
    SELECT
        (SELECT COUNT(*) FROM department) AS departments,
        (SELECT COUNT(*) FROM doctor) AS doctors,
        (SELECT COUNT(*) FROM nurse) AS nurses,
        (SELECT COUNT(*) FROM administrative) AS administrative_staff,
        (SELECT COUNT(*) FROM patient) AS patients,
        (SELECT COUNT(*) FROM hospitalization) AS hospitalizations,
        (SELECT COUNT(*) FROM prescription) AS prescriptions,
        (SELECT COUNT(*) FROM procedure_room) AS procedure_rooms,
        (SELECT COUNT(*) FROM medical_procedure) AS medical_procedures,
        (SELECT COUNT(*) FROM lab_test) AS lab_tests,
        (SELECT COUNT(*) FROM triage_record) AS triage_records,
        (SELECT COUNT(*) FROM evaluation) AS evaluations,
        (SELECT COUNT(*) FROM doctor_evaluation) AS doctor_evaluations;
END //

DELIMITER ;

CALL generate_dummy_data();

DROP PROCEDURE IF EXISTS generate_dummy_data;
