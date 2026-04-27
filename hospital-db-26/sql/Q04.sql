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
