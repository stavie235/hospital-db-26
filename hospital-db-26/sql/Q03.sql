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
