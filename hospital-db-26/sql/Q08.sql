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
