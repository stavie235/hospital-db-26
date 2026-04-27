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
