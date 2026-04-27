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
