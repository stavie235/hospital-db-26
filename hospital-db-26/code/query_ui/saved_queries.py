SAVED_QUERIES = [
    {
        "id": "q01-revenue-department-year-ken",
        "title": "Q01 Revenue by Department, Year, KEN",
        "category": "Assignment",
        "description": "Total hospital revenue by department/year/KEN, split into base KEN cost, extra charge after ALOS, and insurance provider distribution.",
        "visualization": {"type": "bar", "xKey": "department_year_ken", "yKeys": ["total_revenue"]},
        "sql": """
SELECT CONCAT(d.name, ' / ', YEAR(h.admission_date), ' / ', h.ken_code) AS department_year_ken,
       d.name AS department,
       YEAR(h.admission_date) AS admission_year,
       h.ken_code,
       p.insurance_provider,
       COUNT(*) AS hospitalizations,
       ROUND(SUM(k.base_cost), 2) AS base_ken_revenue,
       ROUND(SUM(
           CASE
               WHEN h.discharge_date IS NOT NULL
                AND DATEDIFF(h.discharge_date, h.admission_date) > k.alos_days
               THEN GREATEST(COALESCE(h.total_cost, k.base_cost) - k.base_cost, 0)
               ELSE 0
           END
       ), 2) AS extra_alos_revenue,
       ROUND(SUM(COALESCE(h.total_cost, k.base_cost)), 2) AS total_revenue
FROM hospitalization h
JOIN department d ON d.department_id = h.department_id
JOIN patient p ON p.patient_id = h.patient_id
LEFT JOIN ken k ON k.ken_code = h.ken_code
GROUP BY d.department_id, d.name, YEAR(h.admission_date), h.ken_code, p.insurance_provider
ORDER BY admission_year, department, h.ken_code, p.insurance_provider;
""".strip(),
    },
    {
        "id": "q02-doctors-by-specialty-duty-procedures",
        "title": "Q02 Doctors by Specialty",
        "category": "Assignment",
        "description": "Doctors in the chosen specialty, whether they had a duty shift in the current year, and how many procedures they performed as primary surgeons.",
        "visualization": {"type": "bar", "xKey": "doctor", "yKeys": ["primary_surgeon_procedures"]},
        "sql": """
WITH params AS (
    SELECT 'Χειρουργική' AS selected_specialty
)
SELECT doc.staff_id,
       CONCAT(st.first_name, ' ', st.last_name) AS doctor,
       doc.specialty,
       doc.`rank`,
       CASE WHEN COUNT(DISTINCT sh.shift_id) > 0 THEN 'yes' ELSE 'no' END AS had_shift_current_year,
       COUNT(DISTINCT mp.procedure_id) AS primary_surgeon_procedures
FROM params
JOIN doctor doc ON doc.specialty = params.selected_specialty
JOIN staff st ON st.staff_id = doc.staff_id
LEFT JOIN shift_assignment sa ON sa.staff_id = doc.staff_id
LEFT JOIN shift sh
  ON sh.shift_id = sa.shift_id
 AND YEAR(sh.shift_date) = YEAR(CURDATE())
LEFT JOIN medical_procedure mp
  ON mp.primary_surgeon_id = doc.staff_id
 AND YEAR(mp.start_time) = YEAR(CURDATE())
GROUP BY doc.staff_id, doctor, doc.specialty, doc.`rank`
ORDER BY primary_surgeon_procedures DESC, doctor;
""".strip(),
    },
    {
        "id": "q03-repeat-patients-same-department",
        "title": "Q03 Repeat Patients Same Department",
        "category": "Assignment",
        "description": "Patients hospitalized more than three times in the same department, with their total hospitalization cost.",
        "visualization": {"type": "bar", "xKey": "patient", "yKeys": ["hospitalizations", "total_cost"]},
        "sql": """
SELECT p.patient_id,
       CONCAT(p.first_name, ' ', p.last_name) AS patient,
       d.name AS department,
       COUNT(*) AS hospitalizations,
       ROUND(SUM(COALESCE(h.total_cost, 0)), 2) AS total_cost
FROM hospitalization h
JOIN patient p ON p.patient_id = h.patient_id
JOIN department d ON d.department_id = h.department_id
GROUP BY p.patient_id, patient, d.department_id, d.name
HAVING COUNT(*) > 3
ORDER BY hospitalizations DESC, total_cost DESC, patient;
""".strip(),
    },
    {
        "id": "q04-doctor-evaluation-summary",
        "title": "Q04 Doctor Evaluation Summary",
        "category": "Assignment",
        "description": "For doctor_id 2, average medical-care evaluations and average overall hospitalization impression from the same hospitalizations.",
        "visualization": {"type": "bar", "xKey": "doctor", "yKeys": ["avg_medical_care", "avg_overall_hospitalization"]},
        "sql": """
WITH params AS (
    SELECT 2 AS selected_doctor_id
)
SELECT doc.staff_id AS doctor_id,
       CONCAT(st.first_name, ' ', st.last_name) AS doctor,
       doc.specialty,
       COUNT(de.eval_id) AS doctor_evaluations,
       ROUND(AVG(de.medical_care), 2) AS avg_medical_care,
       ROUND(AVG(ev.overall), 2) AS avg_overall_hospitalization
FROM params
JOIN doctor doc ON doc.staff_id = params.selected_doctor_id
JOIN staff st ON st.staff_id = doc.staff_id
JOIN doctor_evaluation de ON de.doctor_id = doc.staff_id
JOIN evaluation ev ON ev.hospitalization_id = de.hospitalization_id
GROUP BY doc.staff_id, doctor, doc.specialty;
""".strip(),
    },
    {
        "id": "q05-young-surgeons",
        "title": "Q05 Young Doctors With Most Surgeries",
        "category": "Assignment",
        "description": "Doctors younger than 35 ranked by surgical procedures performed as primary surgeons.",
        "visualization": {"type": "bar", "xKey": "doctor", "yKeys": ["surgeries_as_primary"]},
        "sql": """
SELECT doc.staff_id AS doctor_id,
       CONCAT(st.first_name, ' ', st.last_name) AS doctor,
       st.age,
       doc.specialty,
       COUNT(mp.procedure_id) AS surgeries_as_primary
FROM doctor doc
JOIN staff st ON st.staff_id = doc.staff_id
JOIN medical_procedure mp ON mp.primary_surgeon_id = doc.staff_id
JOIN procedure_catalog pc
  ON pc.procedure_code = mp.procedure_code
 AND pc.category = 'χειρουργική'
WHERE st.age < 35
GROUP BY doc.staff_id, doctor, st.age, doc.specialty
ORDER BY surgeries_as_primary DESC, doctor
LIMIT 20;
""".strip(),
    },
    {
        "id": "q06-patient-history",
        "title": "Q06 Patient Hospitalization History",
        "category": "Assignment",
        "description": "For patient_id 8, hospitalization history, ICD-10 diagnoses, cost per stay, and the patient's average evaluation.",
        "visualization": {"type": "bar", "xKey": "hospitalization_id", "yKeys": ["total_cost", "patient_avg_overall"]},
        "sql": """
WITH params AS (
    SELECT 8 AS selected_patient_id
),
patient_eval AS (
    SELECT h.patient_id,
           ROUND(AVG(ev.overall), 2) AS patient_avg_overall
    FROM hospitalization h
    JOIN evaluation ev ON ev.hospitalization_id = h.hospitalization_id
    GROUP BY h.patient_id
)
SELECT h.hospitalization_id,
       CONCAT(p.first_name, ' ', p.last_name) AS patient,
       d.name AS department,
       h.admission_date,
       h.discharge_date,
       h.icd10_code,
       i.description AS icd10_diagnosis,
       ROUND(COALESCE(h.total_cost, 0), 2) AS total_cost,
       pe.patient_avg_overall
FROM params
JOIN patient p ON p.patient_id = params.selected_patient_id
JOIN hospitalization h ON h.patient_id = p.patient_id
JOIN department d ON d.department_id = h.department_id
LEFT JOIN ICD10 i ON i.icd_code = h.icd10_code
LEFT JOIN patient_eval pe ON pe.patient_id = p.patient_id
ORDER BY h.admission_date, h.hospitalization_id;
""".strip(),
    },
    {
        "id": "q07-substance-allergy-drug-counts",
        "title": "Q07 Allergies and Drug Substances",
        "category": "Assignment",
        "description": "For each active substance, number of allergic patients and number of drugs containing it.",
        "visualization": {"type": "bar", "xKey": "substance_name", "yKeys": ["allergic_patients", "drugs_containing_substance"]},
        "sql": """
SELECT a.substance_id,
       LEFT(a.substance_name, 90) AS substance_name,
       COUNT(DISTINCT pa.patient_id) AS allergic_patients,
       COUNT(DISTINCT ds.drug_id) AS drugs_containing_substance
FROM active_substance a
LEFT JOIN patient_allergy pa ON pa.substance_id = a.substance_id
LEFT JOIN drug_substance ds ON ds.substance_id = a.substance_id
GROUP BY a.substance_id, a.substance_name
ORDER BY allergic_patients DESC, drugs_containing_substance DESC, substance_name
LIMIT 100;
""".strip(),
    },
    {
        "id": "q08-staff-without-duty",
        "title": "Q08 Staff Without Duty",
        "category": "Assignment",
        "description": "Eligible staff who do not have a scheduled duty shift on 2026-04-06 in department 1.",
        "visualization": {"type": "table"},
        "sql": """
WITH params AS (
    SELECT DATE('2026-04-06') AS selected_date,
           1 AS selected_department_id
),
eligible_staff AS (
    SELECT st.staff_id,
           CONCAT(st.first_name, ' ', st.last_name) AS staff_member,
           'doctor' AS staff_type,
           doc.specialty AS subclass,
           dd.department_id
    FROM staff st
    JOIN doctor doc ON doc.staff_id = st.staff_id
    JOIN doctor_department dd ON dd.staff_id = doc.staff_id
    UNION ALL
    SELECT st.staff_id,
           CONCAT(st.first_name, ' ', st.last_name) AS staff_member,
           'nurse' AS staff_type,
           n.`rank` AS subclass,
           n.department_id
    FROM staff st
    JOIN nurse n ON n.staff_id = st.staff_id
    UNION ALL
    SELECT st.staff_id,
           CONCAT(st.first_name, ' ', st.last_name) AS staff_member,
           'administrative' AS staff_type,
           a.role AS subclass,
           a.department_id
    FROM staff st
    JOIN administrative a ON a.staff_id = st.staff_id
)
SELECT es.staff_id,
       es.staff_member,
       es.staff_type,
       es.subclass,
       d.name AS department,
       params.selected_date
FROM params
JOIN eligible_staff es ON es.department_id = params.selected_department_id
JOIN department d ON d.department_id = es.department_id
WHERE NOT EXISTS (
    SELECT 1
    FROM shift_assignment sa
    JOIN shift sh ON sh.shift_id = sa.shift_id
    WHERE sa.staff_id = es.staff_id
      AND sh.department_id = params.selected_department_id
      AND sh.shift_date = params.selected_date
)
ORDER BY es.staff_type, es.subclass, es.staff_member;
""".strip(),
    },
    {
        "id": "q09-same-annual-length",
        "title": "Q09 Same Annual Stay Length",
        "category": "Assignment",
        "description": "Patients with the same total hospitalized days within a year, where the annual total is above 15 days.",
        "visualization": {"type": "bar", "xKey": "patient", "yKeys": ["total_days_in_year", "patients_with_same_days"]},
        "sql": """
WITH patient_year_days AS (
    SELECT p.patient_id,
           CONCAT(p.first_name, ' ', p.last_name) AS patient,
           YEAR(h.admission_date) AS admission_year,
           SUM(DATEDIFF(COALESCE(h.discharge_date, CURDATE()), h.admission_date)) AS total_days_in_year
    FROM patient p
    JOIN hospitalization h ON h.patient_id = p.patient_id
    GROUP BY p.patient_id, patient, YEAR(h.admission_date)
),
shared_lengths AS (
    SELECT admission_year,
           total_days_in_year,
           COUNT(*) AS patients_with_same_days
    FROM patient_year_days
    WHERE total_days_in_year > 15
    GROUP BY admission_year, total_days_in_year
    HAVING COUNT(*) > 1
)
SELECT pyd.admission_year,
       pyd.patient_id,
       pyd.patient,
       pyd.total_days_in_year,
       sl.patients_with_same_days
FROM patient_year_days pyd
JOIN shared_lengths sl
  ON sl.admission_year = pyd.admission_year
 AND sl.total_days_in_year = pyd.total_days_in_year
ORDER BY pyd.admission_year, pyd.total_days_in_year DESC, pyd.patient;
""".strip(),
    },
    {
        "id": "q10-top-substance-pairs",
        "title": "Q10 Top Substance Pairs",
        "category": "Assignment",
        "description": "Top-3 active-substance pairs prescribed concurrently to the same patient during the same hospitalization.",
        "visualization": {"type": "bar", "xKey": "substance_pair", "yKeys": ["occurrences"]},
        "sql": """
SELECT CONCAT(LEFT(s1.substance_name, 45), ' + ', LEFT(s2.substance_name, 45)) AS substance_pair,
       s1.substance_name AS substance_1,
       s2.substance_name AS substance_2,
       COUNT(DISTINCT CONCAT(p1.hospitalization_id, ':', p1.patient_id)) AS occurrences
FROM prescription p1
JOIN prescription p2
  ON p2.hospitalization_id = p1.hospitalization_id
 AND p2.patient_id = p1.patient_id
 AND p2.prescription_id > p1.prescription_id
 AND p1.start_date <= COALESCE(p2.end_date, p2.start_date)
 AND p2.start_date <= COALESCE(p1.end_date, p1.start_date)
JOIN drug_substance ds1 ON ds1.drug_id = p1.drug_id
JOIN drug_substance ds2
  ON ds2.drug_id = p2.drug_id
 AND ds2.substance_id > ds1.substance_id
JOIN active_substance s1 ON s1.substance_id = ds1.substance_id
JOIN active_substance s2 ON s2.substance_id = ds2.substance_id
GROUP BY s1.substance_id, s1.substance_name, s2.substance_id, s2.substance_name
ORDER BY occurrences DESC, substance_pair
LIMIT 3;
""".strip(),
    },
    {
        "id": "q11-doctors-five-fewer-than-top",
        "title": "Q11 Doctors Five Fewer Than Top",
        "category": "Assignment",
        "description": "Doctors whose current-year procedure count is at least five fewer than the top current-year primary surgeon.",
        "visualization": {"type": "bar", "xKey": "doctor", "yKeys": ["current_year_procedures", "top_current_year_procedures"]},
        "sql": """
WITH procedure_counts AS (
    SELECT doc.staff_id,
           CONCAT(st.first_name, ' ', st.last_name) AS doctor,
           COUNT(mp.procedure_id) AS current_year_procedures
    FROM doctor doc
    JOIN staff st ON st.staff_id = doc.staff_id
    LEFT JOIN medical_procedure mp
      ON mp.primary_surgeon_id = doc.staff_id
     AND YEAR(mp.start_time) = YEAR(CURDATE())
    GROUP BY doc.staff_id, doctor
),
top_count AS (
    SELECT MAX(current_year_procedures) AS top_current_year_procedures
    FROM procedure_counts
)
SELECT pc.staff_id,
       pc.doctor,
       pc.current_year_procedures,
       tc.top_current_year_procedures,
       tc.top_current_year_procedures - pc.current_year_procedures AS procedures_behind_top
FROM procedure_counts pc
CROSS JOIN top_count tc
WHERE tc.top_current_year_procedures - pc.current_year_procedures >= 5
ORDER BY procedures_behind_top DESC, pc.doctor;
""".strip(),
    },
    {
        "id": "q12-weekly-staffing-by-subclass",
        "title": "Q12 Weekly Staffing by Subclass",
        "category": "Assignment",
        "description": "Scheduled staff counts by department, shift, and subclass for the week 2026-04-06 to 2026-04-12, including the minimum required count by staff class.",
        "visualization": {"type": "bar", "xKey": "department_shift_subclass", "yKeys": ["scheduled_staff", "minimum_required_for_class"]},
        "sql": """
WITH params AS (
    SELECT DATE('2026-04-06') AS week_start,
           DATE('2026-04-12') AS week_end
),
assigned_staff AS (
    SELECT sh.shift_id,
           sh.department_id,
           sh.shift_date,
           sh.shift_type,
           st.staff_id,
           st.staff_type,
           doc.specialty AS subclass
    FROM shift sh
    JOIN shift_assignment sa ON sa.shift_id = sh.shift_id
    JOIN staff st ON st.staff_id = sa.staff_id
    JOIN doctor doc ON doc.staff_id = st.staff_id
    UNION ALL
    SELECT sh.shift_id,
           sh.department_id,
           sh.shift_date,
           sh.shift_type,
           st.staff_id,
           st.staff_type,
           n.`rank` AS subclass
    FROM shift sh
    JOIN shift_assignment sa ON sa.shift_id = sh.shift_id
    JOIN staff st ON st.staff_id = sa.staff_id
    JOIN nurse n ON n.staff_id = st.staff_id
    UNION ALL
    SELECT sh.shift_id,
           sh.department_id,
           sh.shift_date,
           sh.shift_type,
           st.staff_id,
           st.staff_type,
           a.role AS subclass
    FROM shift sh
    JOIN shift_assignment sa ON sa.shift_id = sh.shift_id
    JOIN staff st ON st.staff_id = sa.staff_id
    JOIN administrative a ON a.staff_id = st.staff_id
)
SELECT CONCAT(d.name, ' / ', assigned_staff.shift_date, ' / ', assigned_staff.shift_type, ' / ', assigned_staff.subclass) AS department_shift_subclass,
       d.name AS department,
       assigned_staff.shift_date,
       assigned_staff.shift_type,
       assigned_staff.staff_type,
       assigned_staff.subclass,
       COUNT(DISTINCT assigned_staff.staff_id) AS scheduled_staff,
       CASE assigned_staff.staff_type
           WHEN 'doctor' THEN 3
           WHEN 'nurse' THEN 6
           WHEN 'administrative' THEN 2
       END AS minimum_required_for_class
FROM params
JOIN assigned_staff
  ON assigned_staff.shift_date BETWEEN params.week_start AND params.week_end
JOIN department d ON d.department_id = assigned_staff.department_id
GROUP BY d.department_id,
         d.name,
         assigned_staff.shift_date,
         assigned_staff.shift_type,
         assigned_staff.staff_type,
         assigned_staff.subclass
ORDER BY assigned_staff.shift_date,
         d.name,
         FIELD(assigned_staff.shift_type, 'morning', 'afternoon', 'night'),
         assigned_staff.staff_type,
         assigned_staff.subclass;
""".strip(),
    },
    {
        "id": "q13-doctor-supervision-hierarchy",
        "title": "Q13 Doctor Supervision Hierarchy",
        "category": "Assignment",
        "description": "Recursive supervisor chain for every doctor, from direct supervisor upward to the director level.",
        "visualization": {"type": "table"},
        "sql": """
WITH RECURSIVE supervision_chain AS (
    SELECT doc.staff_id AS doctor_id,
           CONCAT(st.first_name, ' ', st.last_name) AS doctor,
           doc.supervisor_id,
           sup.staff_id AS supervisor_staff_id,
           CONCAT(sup_st.first_name, ' ', sup_st.last_name) AS supervisor,
           sup.`rank` AS supervisor_rank,
           1 AS supervision_level
    FROM doctor doc
    JOIN staff st ON st.staff_id = doc.staff_id
    JOIN doctor sup ON sup.staff_id = doc.supervisor_id
    JOIN staff sup_st ON sup_st.staff_id = sup.staff_id

    UNION ALL

    SELECT sc.doctor_id,
           sc.doctor,
           sup.supervisor_id,
           next_sup.staff_id AS supervisor_staff_id,
           CONCAT(next_sup_st.first_name, ' ', next_sup_st.last_name) AS supervisor,
           next_sup.`rank` AS supervisor_rank,
           sc.supervision_level + 1 AS supervision_level
    FROM supervision_chain sc
    JOIN doctor sup ON sup.staff_id = sc.supervisor_staff_id
    JOIN doctor next_sup ON next_sup.staff_id = sup.supervisor_id
    JOIN staff next_sup_st ON next_sup_st.staff_id = next_sup.staff_id
)
SELECT doctor_id,
       doctor,
       supervision_level,
       supervisor_staff_id,
       supervisor,
       supervisor_rank
FROM supervision_chain
ORDER BY doctor, supervision_level;
""".strip(),
    },
    {
        "id": "q14-icd-categories-same-admissions",
        "title": "Q14 ICD Categories Same Admissions",
        "category": "Assignment",
        "description": "ICD-10 categories with the same admission count in two consecutive years, requiring at least five cases in each year.",
        "visualization": {"type": "bar", "xKey": "icd_category", "yKeys": ["admissions_year_1", "admissions_year_2"]},
        "sql": """
WITH category_year_counts AS (
    SELECT i.category AS icd_category,
           YEAR(h.admission_date) AS admission_year,
           COUNT(*) AS admissions
    FROM hospitalization h
    JOIN ICD10 i ON i.icd_code = h.icd10_code
    GROUP BY i.category, YEAR(h.admission_date)
)
SELECT c1.icd_category,
       c1.admission_year AS year_1,
       c2.admission_year AS year_2,
       c1.admissions AS admissions_year_1,
       c2.admissions AS admissions_year_2
FROM category_year_counts c1
JOIN category_year_counts c2
  ON c2.icd_category = c1.icd_category
 AND c2.admission_year = c1.admission_year + 1
 AND c2.admissions = c1.admissions
WHERE c1.admissions >= 5
  AND c2.admissions >= 5
ORDER BY c1.icd_category, c1.admission_year;
""".strip(),
    },
    {
        "id": "q15-triage-urgency-distribution",
        "title": "Q15 Triage Urgency Distribution",
        "category": "Assignment",
        "description": "Triage distribution by urgency level, average wait time, admission percentage, and referral distribution by department.",
        "visualization": {"type": "bar", "xKey": "urgency_department", "yKeys": ["triage_cases", "avg_wait_minutes", "hospitalization_pct"]},
        "sql": """
SELECT CONCAT('Level ', tr.urgency_level, ' / ', COALESCE(d.name, 'No hospitalization')) AS urgency_department,
       tr.urgency_level,
       COALESCE(d.name, 'No hospitalization') AS referral_department,
       COUNT(*) AS triage_cases,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, tr.arrival_time, tr.outcome_time)), 2) AS avg_wait_minutes,
       ROUND(100 * SUM(CASE WHEN tr.hospitalization_id IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS hospitalization_pct
FROM triage_record tr
LEFT JOIN hospitalization h ON h.hospitalization_id = tr.hospitalization_id
LEFT JOIN department d ON d.department_id = h.department_id
GROUP BY tr.urgency_level, referral_department
ORDER BY tr.urgency_level, triage_cases DESC, referral_department;
""".strip(),
    },
]

DEFAULT_QUERY_ID = SAVED_QUERIES[0]["id"]
