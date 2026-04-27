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
