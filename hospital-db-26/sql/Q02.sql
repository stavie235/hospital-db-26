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
