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
