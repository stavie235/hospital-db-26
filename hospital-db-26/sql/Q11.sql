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
