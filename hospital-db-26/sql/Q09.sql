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
