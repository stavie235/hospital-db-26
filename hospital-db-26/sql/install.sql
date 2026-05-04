-- =====================================================
-- install.sql
-- Γενικό Νοσοκομείο «Υγειόπολης» - Database Schema
-- Βάσεις Δεδομένων, ΣΗΜΜΥ, 2025-2026
-- =====================================================

DROP DATABASE IF EXISTS hospital;
CREATE DATABASE hospital CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hospital;

-- =====================================================
-- 1. ΠΡΟΣΩΠΙΚΟ (Staff hierarchy)
-- =====================================================

-- Γονικός πίνακας προσωπικού
CREATE TABLE staff (
    staff_id      INT           AUTO_INCREMENT,
    amka          CHAR(11)   NOT NULL,
    first_name    VARCHAR(50)   NOT NULL,
    last_name     VARCHAR(50)   NOT NULL,
    age           INT,
    email         VARCHAR(100),
    phone         VARCHAR(15),
    hiring_date   DATE          NOT NULL,
    staff_type    VARCHAR(20)   NOT NULL,
    photo_url     TEXT,
    description   TEXT,

    PRIMARY KEY (staff_id),
    UNIQUE (amka),
    
    CHECK (staff_type IN ('doctor', 'nurse', 'administrative')),
    CHECK (age >= 18 AND age <= 80),
    CHECK (email LIKE '%_@_%.__%' OR email IS NULL)
);

-- Ιατροί (ISA: κληρονομεί από staff)
-- supervisor_id = self-referencing FK
CREATE TABLE doctor (
    staff_id       INT,
    license_number VARCHAR(50)  NOT NULL,
    specialty      VARCHAR(80) NOT NULL,
    `rank`         VARCHAR(30)  NOT NULL,
    supervisor_id  INT,

    PRIMARY KEY (staff_id),
    UNIQUE (license_number),

    FOREIGN KEY (staff_id)      REFERENCES staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE,            -- if u get deleted from stuff u are deleted from doctor
    FOREIGN KEY (supervisor_id) REFERENCES doctor(staff_id)
        ON DELETE SET NULL ON UPDATE CASCADE,          -- if supervisor deleted u dont get deleted

    CHECK (`rank` IN ('Ειδικευόμενος', 'Επιμελητής Β', 'Επιμελητής Α', 'Διευθυντής'))
);

-- Νοσηλευτές (ISA: κληρονομεί από staff)
-- department_id FK προστίθεται μετά με ALTER TABLE
CREATE TABLE nurse (
    staff_id      INT,
    `rank`        VARCHAR(30)  NOT NULL,
    department_id INT          NOT NULL,

    PRIMARY KEY (staff_id),

    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CHECK (`rank` IN ('Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος'))
);

-- Διοικητικό προσωπικό (ISA: κληρονομεί από staff)
-- department_id FK προστίθεται μετά με ALTER TABLE
CREATE TABLE administrative (
    staff_id        INT,
    role            VARCHAR(50)  NOT NULL,
    office_name     VARCHAR(50),
    department_id   INT          NOT NULL,

    PRIMARY KEY (staff_id),

    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- 2. ΤΜΗΜΑΤΑ & ΥΠΟΔΟΜΗ (Departments, Beds, Shifts)
-- =====================================================

-- Τμήματα νοσοκομείου
CREATE TABLE department (
    department_id  INT           AUTO_INCREMENT,
    name           VARCHAR(100)  NOT NULL,
    description    TEXT,
    num_beds       INT,
    floor_building VARCHAR(50),
    director_id    INT,
    photo_url      TEXT,

    PRIMARY KEY (department_id),
    UNIQUE (name),

    CHECK (num_beds >= 0)
);

-- Λύση κυκλικής εξάρτησης: προσθήκη FKs με ALTER TABLE 
ALTER TABLE department
    ADD CONSTRAINT fk_department_director
    FOREIGN KEY (director_id) REFERENCES doctor(staff_id)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE nurse
    ADD CONSTRAINT fk_nurse_department
    FOREIGN KEY (department_id) REFERENCES department(department_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;     -- if department deleted nurse dont 

ALTER TABLE administrative
    ADD CONSTRAINT fk_administrative_department
    FOREIGN KEY (department_id) REFERENCES department(department_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- Ιατρός <-> Τμήμα (M:N: ένας ιατρός σε πολλά τμήματα)
CREATE TABLE doctor_department (
    staff_id      INT NOT NULL,
    department_id INT NOT NULL,

    PRIMARY KEY (staff_id, department_id),

    FOREIGN KEY (staff_id)      REFERENCES doctor(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Κλίνες (ανήκουν σε τμήμα)
CREATE TABLE bed (
    id        INT          AUTO_INCREMENT,
    `number`  INT          NOT NULL,   -- for nurses identification
    `type`    VARCHAR(30),
    `status`  VARCHAR(30)  DEFAULT 'διαθέσιμη',
    department_id INT          NOT NULL,

    PRIMARY KEY (id),
    UNIQUE (department_id, number),

    FOREIGN KEY (department_id) REFERENCES department(department_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CHECK (status IN ('διαθέσιμη', 'κατειλημμένη', 'υπό συντήρηση'))
);

-- Βάρδιες ανά τμήμα
CREATE TABLE shift (
    shift_id      INT          AUTO_INCREMENT,
    department_id INT          NOT NULL,
    shift_date    DATE         NOT NULL,
    shift_type    VARCHAR(10)  NOT NULL,

    PRIMARY KEY (shift_id),
    UNIQUE (department_id, shift_date, shift_type),

    FOREIGN KEY (department_id) REFERENCES department(department_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CHECK (shift_type IN ('morning', 'afternoon', 'night'))
);

-- Ανάθεση προσωπικού σε βάρδιες (M:N)
CREATE TABLE shift_assignment (
    shift_id INT NOT NULL,
    staff_id INT NOT NULL,

    PRIMARY KEY (shift_id, staff_id),

    FOREIGN KEY (shift_id) REFERENCES shift(shift_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Χειρουργεία / Αίθουσες επεμβάσεων
CREATE TABLE procedure_room (
    room_id     INT           AUTO_INCREMENT,
    room_name   VARCHAR(100)  NOT NULL,
    room_type   VARCHAR(50),
    description TEXT,
    photo_url   TEXT,

    PRIMARY KEY (room_id),

    CHECK (room_type IN ('χειρουργείο', 'αίθουσα επέμβασης'))
);

-- =====================================================
-- 3. ΑΣΘΕΝΕΙΣ (Patients, Contacts, Allergies)
-- =====================================================

-- Ασθενείς
CREATE TABLE patient (
    patient_id         INT           AUTO_INCREMENT, -- or use amka as primary key?
    amka               CHAR(11)   NOT NULL,
    first_name         VARCHAR(50)   NOT NULL,
    last_name          VARCHAR(50)   NOT NULL,
    father_name        VARCHAR(50),
    age                INT,
    gender             CHAR(1),
    weight             DECIMAL(5,2),
    height             DECIMAL(5,2),
    address            TEXT,
    phone              VARCHAR(15),
    email              VARCHAR(100),
    profession         VARCHAR(100),
    nationality        VARCHAR(50),
    insurance_provider VARCHAR(50)   NOT NULL,
    photo_url          TEXT,

    PRIMARY KEY (patient_id),
    UNIQUE (amka),

    CHECK (gender IN ('M', 'F')),
    CHECK (age >= 0 AND age <= 120),
    CHECK (weight > 0 OR weight IS NULL),
    CHECK (height > 0 OR height IS NULL),
    CHECK (LENGTH(amka) = 11),
    CHECK (email LIKE '%_@_%.__%' OR email IS NULL)
);

-- Στοιχεία οικείων ατόμων σε περίπτωση ανάγκης
CREATE TABLE emergency_contact (
    contact_id   INT          AUTO_INCREMENT,
    patient_id   INT          NOT NULL,
    full_name    VARCHAR(100) NOT NULL,
    phone        VARCHAR(20)  NOT NULL,
    relationship VARCHAR(50),

    PRIMARY KEY (contact_id),

    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- =====================================================
-- 4. ΝΟΣΗΛΕΙΑ (Hospitalization & related)
-- =====================================================

-- Κλειστά Ενοποιημένα Νοσήλια (πίνακας αναφοράς κοστολόγησης)
CREATE TABLE ken (
    ken_code    VARCHAR(20),
    description TEXT,
    base_cost   DECIMAL(10,2)  NOT NULL,
    alos_days   INT            NOT NULL,

    PRIMARY KEY (ken_code),

    CHECK (base_cost >= 0),
    CHECK (alos_days > 0)
);

--icd-10
CREATE TABLE ICD10 (
    icd_code    VARCHAR(10)  NOT NULL,
    description VARCHAR(500) NOT NULL,
    category    TEXT NOT NULL,
    PRIMARY KEY (icd_code)
); 

-- Νοσηλείες (κεντρικός πίνακας)
CREATE TABLE hospitalization (
    hospitalization_id INT           AUTO_INCREMENT,
    patient_id         INT           NOT NULL,
    bed_id             INT           NOT NULL,
    department_id      INT           NOT NULL,
    ken_code           VARCHAR(20),
    admission_date     DATE          NOT NULL,
    discharge_date     DATE,
    admission_diagnosis TEXT,
    icd10_code         VARCHAR(10),
    discharge_desc     TEXT,
    total_cost         DECIMAL(10,2),

    PRIMARY KEY (hospitalization_id),

    FOREIGN KEY (patient_id)    REFERENCES patient(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,     
    FOREIGN KEY (bed_id)        REFERENCES bed(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ken_code)      REFERENCES ken(ken_code)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY(icd10_code) REFERENCES ICD10(icd_code)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CHECK (discharge_date IS NULL OR discharge_date >= admission_date),
    CHECK (total_cost IS NULL OR total_cost >= 0)
);

-- Triage (διαλογή ασθενών στα Επείγοντα)
CREATE TABLE triage_record (
    triage_id          INT          AUTO_INCREMENT,
    patient_id         INT          NOT NULL,
    nurse_id           INT          NOT NULL,
    hospitalization_id INT,
    arrival_time       DATETIME     NOT NULL,
    symptoms           TEXT,
    urgency_level      INT          NOT NULL,
    outcome            VARCHAR(50),
    outcome_time       DATETIME     NOT NULL,

    PRIMARY KEY (triage_id),

    FOREIGN KEY (patient_id)         REFERENCES patient(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (nurse_id)           REFERENCES nurse(staff_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    CHECK (outcome_time IS NULL OR outcome_time >= arrival_time),
    CHECK (urgency_level BETWEEN 1 AND 5),
    CHECK (outcome IN ('αποχώρηση', 'νοσηλεία'))
);

-- (α) Αξιολόγηση νοσηλείας (κλίμακα Likert 1-5)
-- Ένα evaluation per νοσηλεία: νοσηλευτική φροντίδα, καθαριότητα, φαγητό, συνολική εμπειρία
CREATE TABLE evaluation (
    evaluation_id      INT  AUTO_INCREMENT,
    hospitalization_id INT  NOT NULL,
    nursing_care       INT  NOT NULL,
    cleanliness        INT  NOT NULL,
    food               INT  NOT NULL,
    overall            INT  NOT NULL,
    comments           TEXT,
    evaluation_date    DATE,

    PRIMARY KEY (evaluation_id),
    UNIQUE (hospitalization_id),

    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CHECK (nursing_care BETWEEN 1 AND 5),
    CHECK (cleanliness  BETWEEN 1 AND 5),
    CHECK (food         BETWEEN 1 AND 5),
    CHECK (overall      BETWEEN 1 AND 5)
);

-- (β) Αξιολόγηση ιατρού (κλίμακα Likert 1-5)
-- Ο ασθενής αξιολογεί κάθε ιατρό που συνταγογράφησε κατά τη νοσηλεία
CREATE TABLE doctor_evaluation (
    eval_id            INT  AUTO_INCREMENT,
    hospitalization_id INT  NOT NULL,
    doctor_id          INT  NOT NULL,
    medical_care       INT  NOT NULL,
    evaluation_date    DATE,

    PRIMARY KEY (eval_id),
    UNIQUE (hospitalization_id, doctor_id),

    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctor(staff_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CHECK (medical_care BETWEEN 1 AND 5)
);

-- Εργαστηριακές εξετάσεις
-- Κατάλογος εργαστηριακών εξετάσεων (πίνακας αναφοράς)
CREATE TABLE lab_test_catalog (
    test_code    VARCHAR(20),
    test_type    VARCHAR(100)    NOT NULL,
    name         TEXT   NOT NULL,
    default_cost DECIMAL(10,2),
    description  TEXT,

    PRIMARY KEY (test_code),

    CHECK (default_cost >= 0 OR default_cost IS NULL)
);

CREATE TABLE lab_test (
    test_id            INT           AUTO_INCREMENT,
    hospitalization_id INT           NOT NULL,
    ordered_by         INT           NOT NULL,
    test_code          VARCHAR(20)   NOT NULL,
    test_date          DATE          NOT NULL,
    result_text        TEXT,
    result_numeric     DECIMAL(10,4),
    measurement_unit   VARCHAR(20),
    cost               DECIMAL(10,2),

    PRIMARY KEY (test_id),

    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ordered_by) REFERENCES doctor(staff_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (test_code) REFERENCES lab_test_catalog(test_code)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CHECK (cost IS NULL OR cost >= 0)
);

-- Κατάλογος ιατρικών πράξεων (πίνακας αναφοράς)
CREATE TABLE procedure_catalog (
    procedure_code VARCHAR(20),
    name           VARCHAR(700)   NOT NULL,
    category       VARCHAR(30)    NOT NULL,
    default_cost   DECIMAL(10,2),  -- ta vazo null alla dn xero giati yparxoun
    description    TEXT,

    PRIMARY KEY (procedure_code),

    CHECK (category IN ('χειρουργική', 'διαγνωστική', 'θεραπευτική')),
    CHECK (default_cost >= 0 OR default_cost IS NULL)
);

-- Ιατρικές πράξεις / Επεμβάσεις
CREATE TABLE medical_procedure (
    procedure_id       INT           AUTO_INCREMENT,
    procedure_code     VARCHAR(20)   NOT NULL,
    hospitalization_id INT           NOT NULL,
    room_id            INT           NOT NULL,
    primary_surgeon_id INT           NOT NULL,
    start_time         DATETIME      NOT NULL,
    end_time           DATETIME,
    actual_cost        DECIMAL(10,2),

    PRIMARY KEY (procedure_id),

    FOREIGN KEY (procedure_code)     REFERENCES procedure_catalog(procedure_code)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (room_id)            REFERENCES procedure_room(room_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (primary_surgeon_id) REFERENCES doctor(staff_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CHECK (end_time IS NULL OR end_time > start_time),
    CHECK (actual_cost IS NULL OR actual_cost >= 0)
);

-- Βοηθοί σε επεμβάσεις (M:N)
CREATE TABLE procedure_assistant (
    procedure_id INT         NOT NULL,
    staff_id     INT         NOT NULL,
    role         VARCHAR(50),

    PRIMARY KEY (procedure_id, staff_id),

    FOREIGN KEY (procedure_id) REFERENCES medical_procedure(procedure_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (staff_id)     REFERENCES staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- 5. ΦΑΡΜΑΚΑ & ΣΥΝΤΑΓΟΓΡΑΦΗΣΗ (Drugs, Substances, Rx)
-- =====================================================

-- Φάρμακα (από EMA Article 57)
CREATE TABLE drug (
    drug_id     INT           AUTO_INCREMENT,
    drug_name   VARCHAR(500)  NOT NULL,
    ema_code    VARCHAR(50),
    description TEXT,

    PRIMARY KEY (drug_id)
);

-- Δραστικές ουσίες
CREATE TABLE active_substance (
    substance_id   INT           AUTO_INCREMENT,
    substance_name VARCHAR(500)  NOT NULL,

    PRIMARY KEY (substance_id),
    UNIQUE (substance_name)
);

-- Φάρμακο <-> Δραστική ουσία (M:N)
CREATE TABLE drug_substance (
    drug_id      INT NOT NULL,
    substance_id INT NOT NULL,

    PRIMARY KEY (drug_id, substance_id),

    FOREIGN KEY (drug_id)      REFERENCES drug(drug_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (substance_id) REFERENCES active_substance(substance_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Αλλεργίες ασθενή σε δραστικές ουσίες (M:N)
CREATE TABLE patient_allergy (
    patient_id   INT NOT NULL,
    substance_id INT NOT NULL,

    PRIMARY KEY (patient_id, substance_id),

    FOREIGN KEY (patient_id)   REFERENCES patient(patient_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (substance_id) REFERENCES active_substance(substance_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Συνταγογράφηση
CREATE TABLE prescription (
    prescription_id    INT          AUTO_INCREMENT,
    hospitalization_id INT          NOT NULL,
    doctor_id          INT          NOT NULL,
    patient_id         INT          NOT NULL,
    drug_id            INT          NOT NULL,
    dosage             VARCHAR(100),
    frequency          VARCHAR(100),
    start_date         DATE         NOT NULL,
    end_date           DATE,

    PRIMARY KEY (prescription_id),
    UNIQUE (doctor_id, patient_id, drug_id, start_date),

    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id)  REFERENCES doctor(staff_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (drug_id)    REFERENCES drug(drug_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CHECK (end_date IS NULL OR end_date >= start_date)
);

-- =====================================================
-- 6. TRIGGERS (Business rules)
-- =====================================================

-- Ειδικευόμενος ΠΡΕΠΕΙ να έχει supervisor
-- Διευθυντής ΔΕΝ ΠΡΕΠΕΙ να έχει supervisor
DELIMITER //
CREATE TRIGGER trg_doctor_supervisor_insert
BEFORE INSERT ON doctor
FOR EACH ROW
BEGIN
    IF NEW.`rank` = 'Ειδικευόμενος' AND NEW.supervisor_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο Ειδικευόμενος πρέπει να έχει επόπτη';
    END IF;
    IF NEW.`rank` = 'Διευθυντής' AND NEW.supervisor_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο Διευθυντής δεν μπορεί να έχει επόπτη';
    END IF;
END //

CREATE TRIGGER trg_doctor_supervisor_update
BEFORE UPDATE ON doctor
FOR EACH ROW
BEGIN
    IF NEW.`rank` = 'Ειδικευόμενος' AND NEW.supervisor_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο Ειδικευόμενος πρέπει να έχει επόπτη';
    END IF;
    IF NEW.`rank` = 'Διευθυντής' AND NEW.supervisor_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο Διευθυντής δεν μπορεί να έχει επόπτη';
    END IF;
END //

CREATE TRIGGER trg_doctor_no_cycle_insert
BEFORE INSERT ON doctor
FOR EACH ROW
BEGIN
    DECLARE current_sup INT;
    DECLARE max_depth INT DEFAULT 0;

    SET current_sup = NEW.supervisor_id;

    WHILE current_sup IS NOT NULL AND max_depth < 50 DO
        IF current_sup = NEW.staff_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Κυκλική αλυσίδα εποπτείας δεν επιτρέπεται';
        END IF;

        SELECT supervisor_id INTO current_sup
        FROM doctor
        WHERE staff_id = current_sup;

        SET max_depth = max_depth + 1;
    END WHILE;
END //

CREATE TRIGGER trg_doctor_no_cycle_update
BEFORE UPDATE ON doctor
FOR EACH ROW
BEGIN
    DECLARE current_sup INT;
    DECLARE max_depth INT DEFAULT 0;

    SET current_sup = NEW.supervisor_id;

    WHILE current_sup IS NOT NULL AND max_depth < 50 DO
        IF current_sup = NEW.staff_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Κυκλική αλυσίδα εποπτείας δεν επιτρέπεται';
        END IF;

        SELECT supervisor_id INTO current_sup
        FROM doctor
        WHERE staff_id = current_sup;

        SET max_depth = max_depth + 1;
    END WHILE;
END //

DELIMITER ;

-- Απαγόρευση συνταγογράφησης αν ο ασθενής είναι
-- αλλεργικός σε δραστική ουσία του φαρμάκου
DELIMITER //
CREATE TRIGGER trg_prescription_allergy_check
BEFORE INSERT ON prescription
FOR EACH ROW
BEGIN
    DECLARE allergy_count INT;

    SELECT COUNT(*) INTO allergy_count
    FROM drug_substance ds
    JOIN patient_allergy pa ON ds.substance_id = pa.substance_id
    WHERE ds.drug_id = NEW.drug_id
      AND pa.patient_id = NEW.patient_id;

    IF allergy_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο ασθενής είναι αλλεργικός σε δραστική ουσία του φαρμάκου';
    END IF;
END //
DELIMITER ;

-- Αξιολογήσεις: κανόνες ολοκληρωμένης νοσηλείας & συνταγογράφησης
DELIMITER //

-- Κανόνας: αξιολόγηση νοσηλείας μόνο αν έχει discharge_date
CREATE TRIGGER trg_evaluation_discharged
BEFORE INSERT ON evaluation
FOR EACH ROW
BEGIN
    DECLARE v_discharge DATE;

    SELECT discharge_date INTO v_discharge
    FROM hospitalization WHERE hospitalization_id = NEW.hospitalization_id;

    IF v_discharge IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Αξιολόγηση επιτρέπεται μόνο σε ολοκληρωμένη νοσηλεία';
    END IF;
END //

-- Κανόνας: αξιολόγηση ιατρού μόνο αν (α) νοσηλεία ολοκληρωμένη
--           και (β) ο ιατρός έχει συνταγογραφήσει σε αυτή τη νοσηλεία
CREATE TRIGGER trg_doctor_evaluation_check
BEFORE INSERT ON doctor_evaluation
FOR EACH ROW
BEGIN
    DECLARE v_discharge DATE;
    DECLARE v_rx_count  INT;

    SELECT discharge_date INTO v_discharge
    FROM hospitalization WHERE hospitalization_id = NEW.hospitalization_id;

    IF v_discharge IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Αξιολόγηση ιατρού επιτρέπεται μόνο σε ολοκληρωμένη νοσηλεία';
    END IF;

    SELECT COUNT(*) INTO v_rx_count
    FROM prescription
    WHERE hospitalization_id = NEW.hospitalization_id
      AND doctor_id = NEW.doctor_id;

    IF v_rx_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο ιατρός δεν έχει συνταγογραφήσει κατά τη νοσηλεία αυτή';
    END IF;
END //

DELIMITER ;

-- =====================================================
-- Βάρδιες: 4 κανόνες εφημεριών
-- =====================================================

-- Κανόνας 1: Μηνιαίο όριο βαρδιών ανά κατηγορία
-- Ιατροί: 15, Νοσηλευτές: 20, Διοικητικό: 25
DELIMITER //
CREATE TRIGGER trg_shift_monthly_limit
BEFORE INSERT ON shift_assignment
FOR EACH ROW
BEGIN
    DECLARE v_staff_type  VARCHAR(20);
    DECLARE v_shift_date  DATE;
    DECLARE v_month_count INT;
    DECLARE v_max_shifts  INT;

    SELECT staff_type INTO v_staff_type
    FROM staff WHERE staff_id = NEW.staff_id;

    SELECT shift_date INTO v_shift_date
    FROM shift WHERE shift_id = NEW.shift_id;

    SELECT COUNT(*) INTO v_month_count
    FROM shift_assignment sa
    JOIN shift s ON sa.shift_id = s.shift_id
    WHERE sa.staff_id = NEW.staff_id
      AND YEAR(s.shift_date)  = YEAR(v_shift_date)
      AND MONTH(s.shift_date) = MONTH(v_shift_date);

    SET v_max_shifts = CASE v_staff_type
        WHEN 'doctor'         THEN 15
        WHEN 'nurse'          THEN 20
        WHEN 'administrative' THEN 25
        ELSE 0
    END;

    IF v_month_count >= v_max_shifts THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Υπέρβαση μηνιαίου ορίου βαρδιών για αυτή την κατηγορία προσωπικού';
    END IF;
END //
DELIMITER ;

-- Κανόνας 2: Ελάχιστο διάστημα ανάπαυσης 8 ωρών μεταξύ βαρδιών
-- morning:   07:00 - 15:00
-- afternoon: 15:00 - 23:00
-- night:     23:00 - 07:00 (+1)
-- Conflict αν: existing_end + 8h > new_start AND new_end + 8h > existing_start
DELIMITER //
CREATE TRIGGER trg_shift_rest_period
BEFORE INSERT ON shift_assignment
FOR EACH ROW
BEGIN
    DECLARE v_new_date  DATE;
    DECLARE v_new_type  VARCHAR(10);
    DECLARE v_new_start DATETIME;
    DECLARE v_new_end   DATETIME;
    DECLARE v_conflict  INT DEFAULT 0;

    SELECT shift_date, shift_type INTO v_new_date, v_new_type
    FROM shift WHERE shift_id = NEW.shift_id;

    IF v_new_type = 'morning' THEN
        SET v_new_start = TIMESTAMP(v_new_date, '07:00:00');
        SET v_new_end   = TIMESTAMP(v_new_date, '15:00:00');
    ELSEIF v_new_type = 'afternoon' THEN
        SET v_new_start = TIMESTAMP(v_new_date, '15:00:00');
        SET v_new_end   = TIMESTAMP(v_new_date, '23:00:00');
    ELSE -- night
        SET v_new_start = TIMESTAMP(v_new_date, '23:00:00');
        SET v_new_end   = TIMESTAMP(DATE_ADD(v_new_date, INTERVAL 1 DAY), '07:00:00');
    END IF;

    SELECT COUNT(*) INTO v_conflict
    FROM shift_assignment sa
    JOIN shift s ON sa.shift_id = s.shift_id
    WHERE sa.staff_id = NEW.staff_id
      AND (
            CASE s.shift_type
                WHEN 'morning'   THEN TIMESTAMP(s.shift_date, '15:00:00')
                WHEN 'afternoon' THEN TIMESTAMP(s.shift_date, '23:00:00')
                ELSE TIMESTAMP(DATE_ADD(s.shift_date, INTERVAL 1 DAY), '07:00:00')
            END + INTERVAL 8 HOUR > v_new_start
          )
      AND (
            v_new_end + INTERVAL 8 HOUR >
            CASE s.shift_type
                WHEN 'morning'   THEN TIMESTAMP(s.shift_date, '07:00:00')
                WHEN 'afternoon' THEN TIMESTAMP(s.shift_date, '15:00:00')
                ELSE TIMESTAMP(s.shift_date, '23:00:00')
            END
          );

    IF v_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Παραβίαση κανόνα ανάπαυσης: απαιτείται διάστημα τουλάχιστον 8 ωρών μεταξύ βαρδιών';
    END IF;
END //
DELIMITER ;

-- Κανόνας 3: Μέγιστο 3 συνεχόμενες νυχτερινές βάρδιες
-- Αν οι 3 προηγούμενες νύχτες ήταν όλες night → απαγόρευση 4ης
DELIMITER //
CREATE TRIGGER trg_shift_consecutive_nights
BEFORE INSERT ON shift_assignment
FOR EACH ROW
BEGIN
    DECLARE v_new_date    DATE;
    DECLARE v_new_type    VARCHAR(10);
    DECLARE v_night_count INT DEFAULT 0;

    SELECT shift_date, shift_type INTO v_new_date, v_new_type
    FROM shift WHERE shift_id = NEW.shift_id;

    IF v_new_type = 'night' THEN
        SELECT COUNT(*) INTO v_night_count
        FROM shift_assignment sa
        JOIN shift s ON sa.shift_id = s.shift_id
        WHERE sa.staff_id = NEW.staff_id
          AND s.shift_type = 'night'
          AND s.shift_date IN (
              DATE_SUB(v_new_date, INTERVAL 1 DAY),
              DATE_SUB(v_new_date, INTERVAL 2 DAY),
              DATE_SUB(v_new_date, INTERVAL 3 DAY)
          );

        IF v_night_count >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Υπέρβαση ορίου: δεν επιτρέπονται περισσότερες από 3 συνεχόμενες νυχτερινές βάρδιες';
        END IF;
    END IF;
END //
DELIMITER ;

-- Κανόνας 4: Ειδικευόμενος απαιτεί Επιμελητή Α ή Διευθυντή στην ίδια βάρδια
DELIMITER //
CREATE TRIGGER trg_shift_trainee_requires_senior
BEFORE INSERT ON shift_assignment
FOR EACH ROW
BEGIN
    DECLARE v_staff_type  VARCHAR(20);
    DECLARE v_rank        VARCHAR(30);
    DECLARE v_senior_count INT DEFAULT 0;

    SELECT staff_type INTO v_staff_type
    FROM staff WHERE staff_id = NEW.staff_id;

    IF v_staff_type = 'doctor' THEN
        SELECT `rank` INTO v_rank
        FROM doctor WHERE staff_id = NEW.staff_id;

        IF v_rank = 'Ειδικευόμενος' THEN
            SELECT COUNT(*) INTO v_senior_count
            FROM shift_assignment sa
            JOIN doctor d ON sa.staff_id = d.staff_id
            WHERE sa.shift_id = NEW.shift_id
              AND d.`rank` IN ('Επιμελητής Α', 'Διευθυντής');

            IF v_senior_count = 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Ειδικευόμενος δεν μπορεί να ανατεθεί σε βάρδια χωρίς Επιμελητη Α ή Διευθυντή';
            END IF;
        END IF;
    END IF;
END //
DELIMITER ;

-- =====================================================
-- ΣΗΜΕΙΩΣΗ: Ο κανόνας ελάχιστης στελέχωσης βάρδιας
-- (≥3 ιατροί, ≥6 νοσηλευτές, ≥2 διοικητικοί) δεν
-- επιβάλλεται μέσω trigger γιατί δεν είναι γνωστό
-- πότε ολοκληρώνεται η καταχώρηση της βάρδιας.
-- Εφαρμόζεται σε επίπεδο εφαρμογής (application layer).
-- =====================================================

-- =====================================================
-- Επεμβάσεις: ταυτόχρονη χρήση χώρου & ιατρού
-- =====================================================

-- Κανόνας: δύο επεμβάσεις δεν μπορούν να γίνονται ταυτόχρονα στον ίδιο χώρο
DELIMITER //
CREATE TRIGGER trg_procedure_room_overlap
BEFORE INSERT ON medical_procedure
FOR EACH ROW
BEGIN
    DECLARE v_conflict INT DEFAULT 0;

    SELECT COUNT(*) INTO v_conflict
    FROM medical_procedure
    WHERE room_id = NEW.room_id
      AND NEW.start_time < COALESCE(end_time, '9999-12-31')
      AND start_time     < COALESCE(NEW.end_time, '9999-12-31');

    IF v_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Υπάρχει ήδη επέμβαση στον ίδιο χώρο αυτή την ώρα';
    END IF;
END //

-- Κανόνας: ο ίδιος ιατρός δεν μπορεί να συμμετέχει σε δύο ταυτόχρονες επεμβάσεις (ως κύριος)
CREATE TRIGGER trg_procedure_doctor_overlap
BEFORE INSERT ON medical_procedure
FOR EACH ROW
BEGIN
    DECLARE v_conflict INT DEFAULT 0;

    -- ως κύριος χειρουργός σε άλλη επέμβαση
    SELECT COUNT(*) INTO v_conflict
    FROM medical_procedure
    WHERE primary_surgeon_id = NEW.primary_surgeon_id
      AND NEW.start_time < COALESCE(end_time, '9999-12-31')
      AND start_time     < COALESCE(NEW.end_time, '9999-12-31');

    IF v_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο ιατρός συμμετέχει ήδη σε άλλη επέμβαση αυτή την ώρα';
    END IF;

    -- ως βοηθός σε άλλη επέμβαση
    SELECT COUNT(*) INTO v_conflict
    FROM procedure_assistant pa
    JOIN medical_procedure mp ON pa.procedure_id = mp.procedure_id
    WHERE pa.staff_id = NEW.primary_surgeon_id
      AND NEW.start_time < COALESCE(mp.end_time, '9999-12-31')
      AND mp.start_time  < COALESCE(NEW.end_time, '9999-12-31');

    IF v_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο ιατρός συμμετέχει ήδη ως βοηθός σε άλλη επέμβαση αυτή την ώρα';
    END IF;
END //

-- Κανόνας: ο ίδιος βοηθός δεν μπορεί σε δύο ταυτόχρονες επεμβάσεις
CREATE TRIGGER trg_procedure_assistant_overlap
BEFORE INSERT ON procedure_assistant
FOR EACH ROW
BEGIN
    DECLARE v_conflict  INT DEFAULT 0;
    DECLARE v_new_start DATETIME;
    DECLARE v_new_end   DATETIME;

    SELECT start_time, end_time INTO v_new_start, v_new_end
    FROM medical_procedure WHERE procedure_id = NEW.procedure_id;

    -- ως κύριος χειρουργός
    SELECT COUNT(*) INTO v_conflict
    FROM medical_procedure
    WHERE primary_surgeon_id = NEW.staff_id
      AND procedure_id      != NEW.procedure_id
      AND v_new_start < COALESCE(end_time, '9999-12-31')
      AND start_time  < COALESCE(v_new_end, '9999-12-31');

    IF v_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο βοηθός είναι ήδη κύριος χειρουργός σε άλλη ταυτόχρονη επέμβαση';
    END IF;

    -- ως βοηθός σε άλλη επέμβαση
    SELECT COUNT(*) INTO v_conflict
    FROM procedure_assistant pa
    JOIN medical_procedure mp ON pa.procedure_id = mp.procedure_id
    WHERE pa.staff_id     = NEW.staff_id
      AND pa.procedure_id != NEW.procedure_id
      AND v_new_start < COALESCE(mp.end_time, '9999-12-31')
      AND mp.start_time < COALESCE(v_new_end, '9999-12-31');

    IF v_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ο βοηθός συμμετέχει ήδη σε άλλη ταυτόχρονη επέμβαση';
    END IF;
END //
DELIMITER ;

-- =====================================================
-- Κλίνες: αυτόματη διαχείριση κατάστασης
-- =====================================================

DELIMITER //
-- Έλεγχος διαθεσιμότητας κλίνης πριν νοσηλεία
CREATE TRIGGER trg_hospitalization_bed_check
BEFORE INSERT ON hospitalization
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(30);

    SELECT status INTO v_status FROM bed WHERE id = NEW.bed_id;

    IF v_status != 'διαθέσιμη' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Η κλίνη δεν είναι διαθέσιμη';
    END IF;
END //

-- Κλίνη → κατειλημμένη μετά την εισαγωγή νοσηλείας
CREATE TRIGGER trg_hospitalization_bed_occupy
AFTER INSERT ON hospitalization
FOR EACH ROW
BEGIN
    UPDATE bed SET status = 'κατειλημμένη' WHERE id = NEW.bed_id;
END //

-- Κλίνη → διαθέσιμη μετά την έξοδο ασθενή
CREATE TRIGGER trg_hospitalization_bed_free
AFTER UPDATE ON hospitalization
FOR EACH ROW
BEGIN
    IF OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL THEN
        UPDATE bed SET status = 'διαθέσιμη' WHERE id = NEW.bed_id;
    END IF;
END //

-- Αυτόματος υπολογισμός total_cost βάσει ΚΕΝ κατά την έξοδο.
-- Η εκφώνηση ορίζει: αν actual_days > alos_days, επιβάλλεται
-- αναλογική πρόσθετη ημερήσια χρέωση = base_cost / alos_days ανά επιπλέον μέρα.
-- Ο trigger εκτελείται BEFORE UPDATE ώστε να θέτει NEW.total_cost
-- απευθείας, χωρίς UPDATE στον ίδιο πίνακα (απαγορεύεται σε trigger).
CREATE TRIGGER trg_hospitalization_cost
BEFORE UPDATE ON hospitalization
FOR EACH ROW
BEGIN
    DECLARE v_base_cost   DECIMAL(10,2);
    DECLARE v_alos_days   INT;
    DECLARE v_actual_days INT;

    IF OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL AND NEW.ken_code IS NOT NULL THEN
        SELECT base_cost, alos_days INTO v_base_cost, v_alos_days
        FROM ken WHERE ken_code = NEW.ken_code;

        SET v_actual_days = DATEDIFF(NEW.discharge_date, NEW.admission_date);

        IF v_actual_days > v_alos_days THEN
            SET NEW.total_cost = v_base_cost + (v_actual_days - v_alos_days) * (v_base_cost / v_alos_days);
        ELSE
            SET NEW.total_cost = v_base_cost;
        END IF;
    END IF;
END //
DELIMITER ;

-- =====================================================
-- 7. INDEXES (Ευρετήρια για βελτιστοποίηση queries)
-- =====================================================

-- Νοσηλείες
CREATE INDEX idx_hospitalization_patient    ON hospitalization(patient_id);   -- Q03, Q06, Q09: JOIN με patient
CREATE INDEX idx_hospitalization_department ON hospitalization(department_id); -- Q01, Q03: JOIN με department
CREATE INDEX idx_hospitalization_admission  ON hospitalization(admission_date); -- Q01, Q09, Q14: GROUP BY YEAR()
CREATE INDEX idx_hospitalization_ken        ON hospitalization(ken_code);       -- Q01: LEFT JOIN με ken
CREATE INDEX idx_hospitalization_icd        ON hospitalization(icd10_code);     -- Q06, Q14: LEFT JOIN με ICD10

-- Ιατροί
CREATE INDEX idx_doctor_specialty   ON doctor(specialty);                -- Q02, Q05: WHERE/GROUP BY specialty
CREATE INDEX idx_doctor_rank        ON doctor(`rank`);                   -- Q13: ιεραρχία εποπτείας ανά rank
CREATE INDEX idx_doctor_supervisor  ON doctor(supervisor_id);           -- Q13: recursive CTE JOIN ON supervisor_id

-- Βάρδιες
CREATE INDEX idx_shift_date      ON shift(shift_date);                          -- Q08, Q12: WHERE/BETWEEN shift_date
CREATE INDEX idx_shift_dept_date ON shift(department_id, shift_date);           -- Q08, Q12: composite φίλτρο dept+ημερομηνία
CREATE INDEX idx_shift_assignment_staff ON shift_assignment(staff_id);          -- Q02, Q08, Q12: JOIN staff σε βάρδιες

-- Εξετάσεις & Επεμβάσεις
CREATE INDEX idx_lab_test_hospitalization ON lab_test(hospitalization_id);      -- γενικό JOIN
CREATE INDEX idx_procedure_surgeon        ON medical_procedure(primary_surgeon_id); -- Q02, Q05, Q11: JOIN χειρουργός
CREATE INDEX idx_procedure_start_time     ON medical_procedure(start_time);     -- Q02, Q11: YEAR(start_time) φίλτρο

-- Προσωπικό
CREATE INDEX idx_staff_age ON staff(age);                                        -- Q05: WHERE age < 35 (range query)

-- Φάρμακα & Ουσίες
CREATE INDEX idx_drug_name               ON drug(drug_name);                    -- load.sql: JOIN κατά φόρτωση
CREATE INDEX idx_drug_substance_drug     ON drug_substance(drug_id);            -- Q10: JOIN ds ON drug_id (148k rows)
CREATE INDEX idx_drug_substance_substance ON drug_substance(substance_id);      -- Q07, Q10: JOIN ds ON substance_id

-- Συνταγογράφηση
CREATE INDEX idx_prescription_patient      ON prescription(patient_id);         -- Q10: JOIN συνταγές ίδιου ασθενή
CREATE INDEX idx_prescription_doctor       ON prescription(doctor_id);          -- trigger: έλεγχος συνταγογράφησης
CREATE INDEX idx_prescription_hospitalization ON prescription(hospitalization_id); -- Q10: self-join ON hospitalization_id

-- Αλλεργίες
CREATE INDEX idx_patient_allergy_substance ON patient_allergy(substance_id);    -- Q07: JOIN ουσία-αλλεργία

-- Αξιολογήσεις
CREATE INDEX idx_triage_urgency             ON triage_record(urgency_level);    -- Q15: GROUP BY urgency_level
CREATE INDEX idx_evaluation_hospitalization ON evaluation(hospitalization_id);  -- Q04, Q06: JOIN αξιολόγηση
CREATE INDEX idx_doctor_evaluation_doctor   ON doctor_evaluation(doctor_id);    -- Q04: JOIN αξιολόγηση γιατρού
